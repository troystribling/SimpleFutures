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
        let expectation_immediate = expectationWithDescription("Immediate future success")
        let expectation_delayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation_immediate.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        future.success(true)
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation_delayed.fulfill()
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

class FutureFailureTests: XCTestCase {
    
    let error = NSError(domain:"SimpleFutures", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Imediate future failure")
        future.failure(self.error)
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
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        future.failure(self.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayed() {
        let future = Future<Bool>()
        let expectation_immediate = expectationWithDescription("Immediate future success")
        let expectation_delayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation_immediate.fulfill()
        }
        future.failure(self.error)
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation_delayed.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromise() {
        let promise = Promise<Bool>()
        let expectation = expectationWithDescription("Success from promise")
        promise.future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        promise.future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        promise.failure(self.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

