//
//  FutureCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/25/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureCompleteWithTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccess() {
        let promise = Promise<Bool>()
        let future = promise.future
        let promiseCompleted = Promise<Bool>()
        let futureCompleted = promiseCompleted.future
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let expectationCompleted = expectationWithDescription("onSuccess fulfilled for completed future")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        futureCompleted.onSuccess {value in
            XCTAssert(value, "futureCompleted onSuccess value invalid")
            expectationCompleted.fulfill()
        }
        futureCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        promise.completeWith(futureCompleted)
        promiseCompleted.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailure() {
        let promise = Promise<Bool>()
        let future = promise.future
        let promiseCompleted = Promise<Bool>()
        let futureCompleted = promiseCompleted.future
        let expectation = expectationWithDescription("onFailure fulfilled for future")
        let expectationCompleted = expectationWithDescription("onFailure fulfilled for completed future")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        futureCompleted.onSuccess {value in
            XCTAssert(false, "futureComleted onSuccess called")
        }
        futureCompleted.onFailure{error in
            expectationCompleted.fulfill()
        }
        promise.completeWith(futureCompleted)
        promiseCompleted.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}

