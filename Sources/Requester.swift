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
            
            let bytes = RequestWriter.write(request: request)
            try socket.write(bytes)
            
            try wait(socket)
            
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
        var fd = pollfd()
        memset(&fd, 0, MemoryLayout<pollfd>.stride)
        fd.fd = socket.fileDescriptor
        fd.events = Int16(POLLIN)
        try ing { poll(&fd, 1, Int32(timeout * 1000)) }
    }
}
