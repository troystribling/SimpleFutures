//
//  FuturesSuccessTests.swift
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
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testImmediateAndDelayed() {
        let future = Future<Bool>()
        let expectationImmediate = expectationWithDescription("Immediate future success")
        let expectationDelayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssertTrue(value, "Delayed Invalid value")
            expectationDelayed.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Delayed onFailure called")
        }
        future.success(true)
        future.onSuccess {value in
            XCTAssertTrue(value, "Immediate Invalid value")
            expectationImmediate.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Immediate onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromise() {
        let promise = Promise<Bool>()
        let expectation = expectationWithDescription("Success from promise")
        promise.future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        promise.future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}

    