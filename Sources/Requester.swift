//
//  Requester.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import Foundation
import Dispatch
import SocketSwift

public typealias ResponseHandler = (Response?, Error?) -> Void
public typealias Port = SocketSwift.Port
public typealias Proxy = (host: String, port: Port)
open class Requester {
    open var timeout: Int
    open var queue: DispatchQueue
    open var request: Request
    open var response: Response?
    open var error: Error?
    open var handler: ResponseHandler? = nil
    open var proxy: Proxy? = nil
    
    public init(request: Request, queue: DispatchQueue, timeout: Int, proxy: Proxy?) {
        self.request = request
        self.queue = queue
        self.timeout = timeout
        self.proxy = proxy
    }
    
    open func startAsync() {
        queue.async {
            self.start()
        }
    }
    
    open func start() {
        reset() // Makes sense if start() called second time
        do {
            let socket = try Socket(.inet)
            
            try connect(socket, request)
            
            let bytes = RequestWriter.write(request: request)
            try socket.write(bytes)
            
            try wait(socket)
            
            self.response = try ResponseParser.parse(socket: socket)
            socket.close()
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
    
    open func wait(_ socket: Socket) throws {
        guard try socket.wait(for: .read, timeout: TimeInterval(timeout) / 1000) else {
            throw Request.Error.timeout
        }
    }
    
    open func connect(_ socket: Socket, hostname: String, port: Port) throws {
        guard let address = (try? socket.addresses(for: hostname, port: port))?.first else {
            throw Request.Error.couldntResolveHost
        }
        
        try socket.connect(address: address)
    }
    
    open func connect(_ socket: Socket, _ request: Request) throws {
        let (hostname, portString) = request.hostnameAndPort
        if let proxy = self.proxy {
            try connect(socket, hostname: proxy.host, port: proxy.port)
            let to = hostname + ":" + (portString ?? "80")
            try socket.write("CONNECT \(to) HTTP/1.0\r\n\r\n".bytes)
            try wait(socket)
            let response = try ResponseParser.parse(socket: socket)
            if response.statusCode != 200 {
                throw Request.Error.proxyConnectionFailed
            }
        } else {
            var port: SocketSwift.Port = 80
            if let p = portString {
                port = Port(p)!
            }
            try connect(socket, hostname: hostname, port: port)
        }
    }
    
    open func reset() {
        response = nil
        error = nil
    }
}
