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
        let ex = expectation(description: "example")
        client.request("http://example.com/", headers: ["Accept": "text/html"]).response { response, error in

            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(response, "response should no be nil")
            let response = response!
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.reasonPhrase, "OK")
            
            XCTAssert(String(cString: response.body).contains("<h1>Example Domain</h1>"))
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ]
}
