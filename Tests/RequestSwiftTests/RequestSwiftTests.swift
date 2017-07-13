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
        
        waitForExpectations()
    }
    
    func testErrorTimeout() {
        let ex = expectation(description: "timeout")
        client.firesImmediately = false
        let requester = client.request("http://httpstat.us/200?sleep=1000")
        requester.timeout = 500 //ms
        client.firesImmediately = true
        requester.startAsync()
        requester.response { response, error in

            XCTAssertNil(response, "response must be nil")
            XCTAssertNotNil(error, "error must not be nil")

            let err = (error as? Request.Error)
            XCTAssertNotNil(err)
            XCTAssertEqual(err, Request.Error.timeout)
            ex.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testErrorDNS() {
        let ex = expectation(description: "dns error")
        client.request("http://aBadDomain.com").response { response, error in
            XCTAssertNil(response, "response must be nil")
            XCTAssertNotNil(error, "error must not be nil")
            
            let err = (error as? Request.Error)
            XCTAssertNotNil(err)
            XCTAssertEqual(err, Request.Error.couldntResolveHost)
            ex.fulfill()
        }
        
        waitForExpectations()
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testErrorTimeout", testErrorTimeout),
        ("testErrorDNS", testErrorDNS),
        ]
}

extension XCTestCase {
    func waitForExpectations() {
        waitForExpectations(timeout: 1.5)
    }
}
