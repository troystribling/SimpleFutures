//
//  FutureAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureAndThenTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessfulAndThen() {
        let promise = Promise<Bool>()
        let future = promise.future
        let andThenExpectation = expectationWithDescription("andThen fulfilled")
        let andThenOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for andThen future")
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let andThen = future.andThen {result in
            switch result {
            case .Success(let resultBox):
                andThenExpectation.fulfill()
            case .Failure(let error):
                XCTAssert(false, "andThen Failure")
            }
        }
        andThen.onSuccess {value in
            XCTAssert(value, "andThen onSuccess value invalid")
            andThenOnSuccessExpectation.fulfill()
        }
        andThen.onFailure {error in
            XCTAssert(false, "andThen onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedAndThen() {
        let promise = Promise<Bool>()
        let future = promise.future
        let andThenExpectation = expectationWithDescription("andThen fulfilled")
        let andThenOnFailureExpectation = expectationWithDescription("onFailure fulfilled for andThen future")
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess value invalid")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        let andThen = future.andThen {result in
            switch result {
            case .Success(let resultBox):
                XCTAssert(false, "andThen Failure")
            case .Failure(let error):
                andThenExpectation.fulfill()
            }
        }
        andThen.onSuccess {value in
            XCTAssert(false, "mapped onFailure called")
        }
        andThen.onFailure {error in
            andThenOnFailureExpectation.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
