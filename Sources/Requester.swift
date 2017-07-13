//
//  Requester.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import Foundation
import SocketSwift

public typealias ResponseHandler = (Response?, Error?) -> Void
open class Requester {
    var timeout = 10
    open var request: Request
    open var response: Response?
    open var error: Error?
    open var handler: ResponseHandler? = nil
    
    public init(request: Request) {
        self.request = request
    }
    
    open func start() {
        do {
            let socket = try Socket(.inet)
            let (hostname, portString) = request.hostnameAndPort
            var port: SocketSwift.Port = 80
            if let p = portString {
                port = Port(p)!
            }
            
            let address = try hostToIp(hostname)
            
            try socket.connect(port: port, address: address)

            try wait(socket)
            
            let bytes = RequestWriter.write(request: request)
            try socket.write(bytes)
            
            self.response = try ResponseParser.parse(socket: socket)
        } catch {
            self.error = error
        }
        handler?(response, error)
    }
    
    open func response(_ handler: @escaping ResponseHandler) {
        self.handler = handler
        if response != nil || error != nil {
            handler(response, error)
        }
    }
    
    
    func hostToIp( _ hostname: String) throws -> String {
        if let a = gethostbyname(hostname) {
            let b = withUnsafePointer(to: &(a.pointee.h_addr_list.pointee)) {
                UnsafePointer<UnsafePointer<in_addr>>(OpaquePointer($0)).pointee.pointee
            }
            let c = inet_ntoa(b)!
            
            return String(cString: c)
        }
        
        try ing { -1 } //thorws :)
        return ""
    }
    func wait(_ socket: Socket) throws {
        func FD_ZERO(_ set: UnsafeMutableRawPointer) {
            memset(set, 0, MemoryLayout<fd_set>.stride)
        }
        
        func FD_SET(_ fd: Int32, _ set: UnsafeMutableRawPointer) {
            let p = OpaquePointer(set)
            let p1 = UnsafeMutablePointer<UInt8>(p)
            let p2 = UnsafeMutableBufferPointer(start: p1, count: MemoryLayout<fd_set>.stride)
            p2[Int(fd)/8] = p2[Int(fd) / 8] | ( 1 << (UInt8(fd % 8)))
        }

        var timeout = timeval(tv_sec: self.timeout, tv_usec: 0)
        var read_fds = fd_set()
        let fd = socket.fileDescriptor
        FD_ZERO(&read_fds)
        FD_SET(fd, &read_fds)
        try ing { select(fd + 1, &read_fds, nil, nil, &timeout) }
    }
}
