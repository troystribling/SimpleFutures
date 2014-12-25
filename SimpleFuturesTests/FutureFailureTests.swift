//
//  FutureFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

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
        let expectation = expectationWithDescription("Imediate future failure")
        promise.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayed() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationImmediate = expectationWithDescription("Immediate future success")
        let expectationDelayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "Delayed onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "Delayed onFailure \(error)")
            expectationDelayed.fulfill()
        }
        promise.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "Immediate onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "Immediate onFailure \(error)")
            expectationImmediate.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

