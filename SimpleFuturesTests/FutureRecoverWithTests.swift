//
//  FutureRecoverWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureRecoverWithTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessful() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let recovered = future.recoverWith {error -> Future<Bool> in
            XCTAssert(false, "recover called")
            return Future<Bool>()
        }
        recovered.onSuccess {value in
            XCTAssert(value, "recovered onSuccess value invalid")
            expectationRecovery.fulfill()
        }
        recovered.onFailure {error in
            XCTAssert(false, "recovered onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testSuccessfulRecovery() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let recovered = future.recoverWith {error -> Future<Bool> in
            let promise = Promise<Bool>()
            promise.success(false)
            return promise.future
        }
        recovered.onSuccess {value in
            XCTAssertFalse(value, "recovered onSuccess invalid value")
            expectationRecovery.fulfill()
        }
        recovered.onFailure {error in
            XCTAssert(false, "recovered onFailure called")
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedRecovery() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let recovered = future.recoverWith {error -> Future<Bool> in
            let promise = Promise<Bool>()
            promise.failure(TestFailure.error)
            return promise.future
        }
        recovered.onSuccess {value in
            XCTAssert(false, "recovered onSuccess callsd")
        }
        recovered.onFailure {error in
            expectationRecovery.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
