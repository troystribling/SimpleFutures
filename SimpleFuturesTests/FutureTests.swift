//
//  FutureTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 12/14/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FuturesSuccessTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Imediate future success")
        future.success(true)
        future.onSuccess {value in
            expectation.fulfill()
            XCTAssertTrue(value, "Invalid value")
        }
        future.onFailure {error in
            XCTAssertNil(error, "\(error)")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            expectation.fulfill()
            XCTAssertTrue(value, "Invalid value")
        }
        future.onFailure {error in
            XCTAssertNil(error, "\(error)")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testPromise() {
        let promise = Promise<Bool>()
        let expectation = expectationWithDescription("Success from promise")
        promise.future.onSuccess {value in
            expectation.fulfill()
            XCTAssertTrue(value, "Invalid value")
        }
        promise.future.onFailure {error in
            XCTAssertNil(error, "\(error)")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
