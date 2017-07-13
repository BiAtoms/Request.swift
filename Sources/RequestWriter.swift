//
//  RequestWriter.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import SocketSwift

//    {method} {fullPath} HTTP/{version}
//    {header}:{optional-whitespaces}{header-value}{optional-whitespaces}
//    .
//    .
//    .
//    {header}:{optional-whitespaces}{header-value}{optional-whitespaces}
//    {CRLF}
//    {body}

//    POST /hello HTTP/1.1
//    Host: www.example.com
//    Content-Length: 51
//    Content-Type: text/plain
//
//    Hello World!
open class RequestWriter {
    
    private let request: Request
    open var version: String { return "1.1" }
    required public init(request: Request) {
        self.request = request
    }
    
    open class func write(request: Request) -> [Byte] {
        return self.init(request: request).write()
    }
    
    open func write() -> [Byte] {
        let requestLine = buildRequestLine()
        request.prepareHeaders()
        let headerFields = buildHeaderFields()
        var raw: [Byte] = requestLine.bytes
        raw.append(contentsOf: headerFields.bytes)
        raw.append(contentsOf: "\r\n".bytes)
        raw.append(contentsOf: request.body)
        return raw
    }
    
    
    internal func buildRequestLine() -> String {
        return "\(request.method.rawValue.uppercased()) \(request.url) HTTP/\(version)\r\n"
    }
    
    internal func buildHeaderFields() -> String {
        var headerField = ""
        request.headers.forEach { (key, value) in
            headerField += "\(key): \(value)\r\n"
        }
        
        return headerField
    }
}

internal extension String {
    var bytes: [Byte] {
        return [Byte](self.utf8)
    }
}
