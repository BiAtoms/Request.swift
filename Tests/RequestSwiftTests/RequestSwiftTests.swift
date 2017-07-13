//
//  RequestSwiftTests.swift
//  RequestSwiftTests
//
//  Created by Orkhan Alikhanov on 7/11/17.
//  Copyright © 2017 BiAtoms. All rights reserved.
//

import XCTest
@testable import RequestSwift

class RequestSwiftTests: XCTestCase {
    struct a {
        static let client = Client()
    }
    
    var client: Client {
        return a.client
    }
    
    func testExample() {
        let ex = expectation(description: "sad")
        client.request("http://google.com/").response { response, error in
            if let err = error {
                print(err)
            } else {
                print(String(cString: response!.body))
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 100)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ]
}
