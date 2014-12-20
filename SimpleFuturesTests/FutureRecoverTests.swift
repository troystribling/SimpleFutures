//
//  FutureRecoverTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureRecoverTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessful() {
        let future = Future<Bool>()
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let recovered = future.recover {error -> Try<Bool> in
            XCTAssert(false, "recover called")
            return Try(false)
        }
        recovered.onSuccess {value in
            XCTAssert(value, "recovered onSuccess value invalid")
            expectationRecovery.fulfill()
        }
        recovered.onFailure {error in
            XCTAssert(false, "recovered onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testSuccessfulRecovery() {
        let future = Future<Bool>()
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let recovered = future.recover {error -> Try<Bool> in
            return Try(false)
        }
        recovered.onSuccess {value in
            XCTAssertFalse(value, "recovered onSuccess invalid value")
            expectationRecovery.fulfill()
        }
        recovered.onFailure {error in
            XCTAssert(false, "recovered onFailure called")
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedRecovery() {
        let future = Future<Bool>()
        let expectationRecovery = expectationWithDescription("OnSuccess fulfilled for recovered future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let recovered = future.recover {error -> Try<Bool> in
            return Try<Bool>(TestFailure.error)
        }
        recovered.onSuccess {value in
            XCTAssert(false, "recovered onSuccess callsd")
        }
        recovered.onFailure {error in
            expectationRecovery.fulfill()
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
