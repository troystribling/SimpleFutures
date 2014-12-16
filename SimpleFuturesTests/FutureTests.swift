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

struct TestFailure {
    static let error = NSError(domain:"SimpleFutures", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

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
            XCTAssertTrue(value, "Invalid value")
            expectationImmediate.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        future.success(true)
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectationDelayed.fulfill()
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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Imediate future failure")
        future.failure(TestFailure.error)
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
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayed() {
        let future = Future<Bool>()
        let expectationImmediate = expectationWithDescription("Immediate future success")
        let expectationDelayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectationImmediate.fulfill()
        }
        future.failure(TestFailure.error)
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectationDelayed.fulfill()
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
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

class FutureCompleteTests : XCTestCase {
  
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImmediateSuccess() {
        let future = Future<Bool>()
        let expectationOnComlpete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationOnSuccess = expectationWithDescription("Immediate onSuccess fullfilled")
        future.complete(Try(true))
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Invalid value")
                expectationOnComlpete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "Failure value")
            }
        }
        future.onSuccess {value in
            XCTAssert(value, "onSuccess value invalid")
            expectationOnSuccess.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateFailure() {
        let future = Future<Bool>()
        let excpectationOnComplete = expectationWithDescription("Immediate onComplete fullfilled")
        let excpectationOnFailure = expectationWithDescription("Immediate onFailure fullfilled")
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayedSuccess() {
        
    }
    
    func testDelayedFailure() {
        
    }
    
    func testImmediateAndDelayedSuccess() {
        
    }
    
    func testImmediateAndDelayedFailure() {
    
    }
    
    func testPromiseSuccess() {
        
    }
    
    func testPromiseFailure() {
        
    }
}

