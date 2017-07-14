//
//  RequestError.swift
//  RequestSwift
//
//  Created by Orkhan Alikhanov on 7/14/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import Foundation

extension Request {
    
    public enum Error: Swift.Error {
        case timeout
        case couldntResolveHost
        case proxyConnectionFailed
    }
    
}
