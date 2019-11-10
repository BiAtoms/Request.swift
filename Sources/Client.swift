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
    open var baseUrl: String?
    public let queue = DispatchQueue(label: "com.biatoms.request-swift." + UUID().uuidString)
    open var firesImmediately: Bool = true
    open var timeout: Int = 5000 // in ms
    
    open var usesSystemProxy: Bool = true
    open var proxy: Proxy? = nil
    
    public init(baseUrl: String? = nil, usesSystemProxy: Bool = true) {
        self.baseUrl = baseUrl
        self.usesSystemProxy = usesSystemProxy
        #if os(Linux)
            try! TLS.initialize()
        #endif
    }
    
    //https://forums.developer.apple.com/thread/65416
    public static func getSystemProxy(for host: String) -> Proxy? {
        #if os(Linux) //CFNetworkCopySystemProxySettings hasn't been implemented. (see https://github.com/apple/swift-corelibs-foundation)
        #else
            guard let url = URL(string: host),
                let proxySettingsUnmanaged = CFNetworkCopySystemProxySettings()
                else { return nil }
            let proxySettings = proxySettingsUnmanaged.takeRetainedValue()
            let proxiesUnmanaged = CFNetworkCopyProxiesForURL(url as CFURL, proxySettings)
            let proxies = proxiesUnmanaged.takeRetainedValue() as! [[String: AnyObject]]
            
            func isValid(type: Any) -> Bool {
                let t = type as! CFString
                let isHttp = url.scheme == "http" && t == kCFProxyTypeHTTP
                let isHttps = url.scheme == "https" && t == kCFProxyTypeHTTPS
                return isHttp || isHttps
            }
            for dict in proxies {
                guard let type = dict[kCFProxyTypeKey as String] else { continue }
                if isValid(type: type) {
                    let host = dict[kCFProxyHostNameKey as String] as! String
                    let port = (dict[kCFProxyPortNumberKey as String] as! NSNumber).intValue
                    return (host, Port(port))
                }
            }
        #endif
        return nil
    }
    
    open func request(_ url: String, method: Request.Method = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: Headers? = nil)
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
        var proxy = self.proxy
        if usesSystemProxy {
            proxy = Client.getSystemProxy(for: url)
        }
        
        let requester = Requester(request: request, queue: queue, timeout: timeout, proxy: proxy)
        
        if firesImmediately {
            requester.startAsync()
        }
        return requester
    }
    
}
