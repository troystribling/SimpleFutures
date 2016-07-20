//
//  FutureFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureFailureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let promise = Promise<Bool>()
        let future = promise.future
        let onFailureExpectation = expectationWithDescription("Imediate future onFailure fulfilled")
        promise.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            self.XCTAssertEqualErrors(error, TestFailure.error)
            onFailureExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let promise = Promise<Bool>()
        let future = promise.future
        let onFailureExpectation = expectationWithDescription("Imediate future onFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            self.XCTAssertEqualErrors(error, TestFailure.error)
            onFailureExpectation.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayed() {
        let promise = Promise<Bool>()
        let future = promise.future
        let onFailureImmediateExpectation = expectationWithDescription("Immediate future onFailure fulfilled")
        let onFailureDelayedExpectation = expectationWithDescription("Delayed future onFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "Delayed onSuccess called")
        }
        future.onFailure {error in
            self.XCTAssertEqualErrors(error, TestFailure.error)
            onFailureDelayedExpectation.fulfill()
        }
        promise.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "Immediate onSuccess called")
        }
        future.onFailure {error in
            self.XCTAssertEqualErrors(error, TestFailure.error)
            onFailureImmediateExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

