//
//  Request.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import SocketSwift
import Foundation

open class Request {
    open var method: Method
    open var url: String
    open var headers: Headers
    open var body: [Byte]

    public init(method: Method, url: String, headers: Headers = [:], body: [Byte] = []) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
    
    open func prepareHeaders() {
        if !headers.keys.contains("User-Agent") {
            headers["User-Agent"] = "Request.swift"
        }
        if body.count != 0 {
            headers[.contentLength] = String(body.count)
        }
        let (hostname, port) = self.hostnameAndPort
        headers["Host"] = port != nil ? "\(hostname):\(port!)" : hostname
    }
    
    //https://tools.ietf.org/html/rfc7230#section-5.3.1
    open var path: String {
        let match = Request.firstMatch(pattern: "^(?:http[s]?:\\/\\/)?[^:\\/\\s]+(?::[0-9]+)?(.*)$", in: self.url)
        let url = NSString(string: self.url) //for NSString.substring
        let path = url.substring(with: match.rangeAt(1))
       	return path.isEmpty ? "/" : path
    }
    
    open var hostnameAndPort: (hostname: String, port: String?) {
        let match = Request.firstMatch(pattern: "^(?:http[s]?:\\/\\/)?([^:\\/\\s]+)(?::([0-9]+))?", in: self.url)
        let url = NSString(string: self.url) //for NSString.substring
       	let hostname = url.substring(with: match.rangeAt(1))
        var port: String? = nil
        if match.rangeAt(2).location != NSNotFound {
            port = url.substring(with: match.rangeAt(2))
        }
        
        return (hostname, port)
    }
    
    private static func firstMatch(pattern: String, in string: String) -> NSTextCheckingResult {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))!
    }
}

#if os(Linux)
    private typealias NSTextCheckingResult = TextCheckingResult
    internal extension TextCheckingResult {
        internal func rangeAt(_ idx: Int) -> NSRange {
            return self.range(at: idx)
        }
    }
#endif


