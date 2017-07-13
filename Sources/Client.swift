//
//  Client.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/11/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import Foundation
import Dispatch
import SocketSwift

public typealias Headers = [String: String]


open class Client {
    var baseUrl: String?
    let queue = DispatchQueue(label: "com.biatoms.request-swift." + UUID().uuidString)
    var firesImmediately: Bool = true
    var timeout: Int = 5000 // in ms
    
    public init(baseUrl: String? = nil) {
        self.baseUrl = baseUrl
    }
    
    
    open func request(_ url: String, method: Method = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: Headers? = nil)
        -> Requester
    {
        var url = url
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            guard let base = baseUrl else {
                fatalError("Base url not set")
            }
            if !base.hasSuffix("/") && !url.hasPrefix("/") {
                url = base + "/" + url
            } else {
                url = base + url
            }
        }
        
        let request = Request(method: method, url: url, headers: headers ?? [:], body: [])
        encoding.encode(request, with: parameters)
        let requester = Requester(request: request, queue: queue, timeout: timeout)
        
        if firesImmediately {
            requester.startAsync()
        }
        return requester
    }
    
}

public enum Method: String {
    case get
    case head
    case post
    case delete
    case patch
    case put
}
