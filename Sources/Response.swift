//
//  Response.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/12/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import SocketSwift

open class Response {
    open var statusCode: Int
    open var reasonPhrase: String
    open var version: String
    
    open var headers: Headers
    open var body: [Byte]
    
    public init(code: Int, reasonPhrase: String, version: String, headers: Headers, body: [Byte]) {
        self.statusCode = code
        self.reasonPhrase = reasonPhrase
        self.version = version
        self.headers = headers
        self.body = body
    }
}
