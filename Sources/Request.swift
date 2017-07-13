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
    
    public init(method: Method, url: String, headers: Headers, body: [Byte]) {
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
    
    open var hostnameAndPort: (hostname: String, port: String?) {
        let regex = try! NSRegularExpression(pattern: "^(?:(?:http[s]?):\\/\\/)?([^:\\/\\s]+)(?::([0-9]+))?", options: .caseInsensitive)
        let match = regex.firstMatch(in: self.url, options: [], range: NSRange(location: 0, length: self.url.characters.count))!
        
        let url = NSString(string: self.url) //for NSString.substring
       	let hostname = url.substring(with: match.rangeAt(1))
        var port: String? = nil
        if match.rangeAt(2).location != NSNotFound {
            port = url.substring(with: match.rangeAt(2))
        }
        
        return (hostname, port)
    }
}

#if os(Linux)
    internal extension TextCheckingResult {
        internal func rangeAt(_ idx: Int) -> NSRange {
            return self.range(at: idx)
        }
    }
#endif


