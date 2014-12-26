//
//  FutureSuccessTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 12/14/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureSuccessTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectation = expectationWithDescription("Imediate future onSuccess fulfilled")
        promise.success(true)
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
        let promise = Promise<Bool>()
        let future = promise.future
        let expectation = expectationWithDescription("Delayed future onSuccess fulfilled")
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testImmediateAndDelayed() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationImmediate = expectationWithDescription("Immediate future onSuccess fulfilled")
        let expectationDelayed = expectationWithDescription("Delayed future onSuccess fulfilled")
        future.onSuccess {value in
            XCTAssertTrue(value, "Delayed Invalid value")
            expectationDelayed.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Delayed onFailure called")
        }
        promise.success(true)
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

}

    