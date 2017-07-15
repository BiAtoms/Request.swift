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
    
    
    func testUrlEncoding() {
        let request = Request(method: .get, url: "http://example.com/?q=123&b=32", headers: [:], body: [])
        URLEncoding.queryString.encode(request, with: ["apple": "ban ana", "ms": "msdn"])
        XCTAssertEqual(request.url, "http://example.com/?q=123&b=32&apple=ban%20ana&ms=msdn")
        
        let request1 = Request(method: .get, url: "http://example.com/", headers: [:], body: [])
        URLEncoding.httpBody.encode(request1, with: ["apple": "ban ana", "ms": "msdn"])
        XCTAssertEqual(request1.body, "apple=ban%20ana&ms=msdn".bytes)
    }
    
    func testRequestPath() {
        var request = Request(method: .get, url: "http://example.com/dir/1/2/search.html?arg=0-a&arg1=1-b")
        XCTAssertEqual(request.path, "/dir/1/2/search.html?arg=0-a&arg1=1-b")
        
        request = Request(method: .get, url: "http://example.com/")
        XCTAssertEqual(request.path, "/")
        
        request = Request(method: .get, url: "http://example.com")
        XCTAssertEqual(request.path, "/")
    }
    
    func testRequestWriter() {
        let body = "This is request's body"
        
        let request = Request(method: .patch, url: "http://www.example.com:443/dir/1/2/search.html?arg=0-a&arg1=1-b", headers: ["User-Agent": "Test"], body: body.bytes)
        let writer = RequestWriter(request: request)
        XCTAssertEqual(writer.buildRequestLine(), "PATCH /dir/1/2/search.html?arg=0-a&arg1=1-b HTTP/1.0\r\n")
        
        //checking sorted array of written string (sperated by "\n\r") instead of the string itself
        //since the headers dictionary had elements with different order on every run
        let writtenStringArray = writer.write().string.components(separatedBy: "\r\n").sorted()
        let requestStringArray = ("PATCH /dir/1/2/search.html?arg=0-a&arg1=1-b HTTP/1.0\r\n"
            + "User-Agent: Test\r\n"
            + "Content-Length: \(body.bytes.count)\r\n"
            + "Host: www.example.com:443\r\n"
            + "\r\n"
            + body).components(separatedBy: "\r\n").sorted()
        
        XCTAssertEqual(writtenStringArray, requestStringArray)
    }

    
    static var allTests = [
        ("testExample", testExample),
        ("testErrorTimeout", testErrorTimeout),
        ("testErrorDNS", testErrorDNS),
        ("testUrlEncoding", testUrlEncoding),
        ("testRequestPath", testErrorDNS),
        ("testRequestWriter", testRequestWriter),
        ]
}

extension XCTestCase {
    func waitForExpectations() {
        waitForExpectations(timeout: 1.5)
    }
}

extension Array where Element == UInt8 {
    var string: String {
        return String(data: Data(bytes: self, count: self.count), encoding: .utf8)!
    }
}
