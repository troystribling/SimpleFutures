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
        let future = Future<Bool>()
        let expectationAndThen = expectationWithDescription("andThen handler fulfilled")
        let expectationAndThenOnSuccess = expectationWithDescription("OnSuccess fulfilled for andThen future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let andThen = future.andThen {result in
            switch result {
            case .Success(let resultBox):
                expectationAndThen.fulfill()
            case .Failure(let error):
                XCTAssert(false, "andThen Failure")
            }
        }
        andThen.onSuccess {value in
            XCTAssert(value, "andThen onSuccess value invalid")
            expectationAndThenOnSuccess.fulfill()
        }
        andThen.onFailure {error in
            XCTAssert(false, "andThen onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedAndThen() {
        let future = Future<Bool>()
        let expectationAndThen = expectationWithDescription("andThen handler fulfilled")
        let expectationAndThenOnFailure = expectationWithDescription("OnFailure fulfilled for andThen future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess value invalid")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let andThen = future.andThen {result in
            switch result {
            case .Success(let resultBox):
                XCTAssert(false, "andThen Failure")
            case .Failure(let error):
                expectationAndThen.fulfill()
            }
        }
        andThen.onSuccess {value in
            XCTAssert(false, "mapped onFailure called")
        }
        andThen.onFailure {error in
            expectationAndThenOnFailure.fulfill()
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
