//
//  ResponseParser.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import SocketSwift



//    HTTP/{version} {status-code} {reason-phrase}
//    {header}:{optional-whitespaces}{header-value}{optional-whitespaces}
//    .
//    .
//    .
//    {header}:{optional-whitespaces}{header-value}{optional-whitespaces}
//    {CRLF}
//    {body}

//    HTTP/1.1 200 OK
//    Date: Mon, 27 Jul 2009 12:28:53 GMT
//    Server: Apache
//    Content-Length: 51
//    Content-Type: text/plain
//
//    Hello World! My payload includes a trailing CRLF.

class ResponseParser {
    private let socket: Socket
    
    required public init(socket: Socket) {
        self.socket = socket
    }
    
    open class func parse(socket: Socket) throws -> Response {
        return try self.init(socket: socket).parse()
    }
    
    open func parse() throws -> Response {
        let (version, code, reason) = try parseStatusLine()
        let headers = parseHeaders()
        var body = [Byte]()
        if let value = headers[.contentLength], let length = Int(value) {
            body = try parseBody(length)
        }
        
        return Response(code: code, reasonPhrase: reason, version: version, headers: headers, body: body)
    }
    
    internal func parseStatusLine() throws -> (version: String, statusCode: Int, reasonPhrase: String) {
        let requestLine = try socket.readLine()
        let parts = requestLine.split(" ", maxSplits: 2)
        return (String(parts[0].dropFirst("HTTP/".count)), Int(parts[1])!, parts[2])
    }
    
    internal func parseHeaders() -> Headers {
        var headers = Headers()
        while let line = try? socket.readLine() {
            let parts = line.split(":", maxSplits: 1)
            let (key, value) = (parts[0].trimmingCharacters(in: .whitespaces), parts[1].trimmingCharacters(in: .whitespaces))
            headers[key] = value
        }
        return headers
    }
    
    internal func parseBody(_ lenght: Int) throws -> [Byte] {
        var body = [Byte]()
        for _ in 0..<lenght { body.append(try socket.read()) }
        return body
    }
}

internal extension String {
    func split(_ separator: Character, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [String] {
        return self.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences).map(String.init)
    }
    
    static var contentLength: String {
        return "Content-Length"
    }
}

internal extension Socket {
    func readLine() throws -> String {
        var line: String = "" //yep it is StringBuilder
        let CR = Byte(13), LF = Byte(10)
        while let byte = try? read(), byte != LF {
            if byte != CR {
                line.append(Character(UnicodeScalar(byte)))
            }
        }
        if line.isEmpty {
            try ing { -1 } //throws :)
        }
        
        return line
    }
}
