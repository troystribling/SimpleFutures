//
//  FutureWithFilterTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/23/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureWithFilterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessfulFilter() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationFilter = expectationWithDescription("fullfilled for filter")
        let expectationFilterFuture = expectationWithDescription("onSuccess fullfilled for filtered future")
        let expectation = expectationWithDescription("onSuccess fullfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSucces value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let filter = future.withFilter {value in
            expectationFilter.fulfill()
            return value
        }
        filter.onSuccess {value in
            XCTAssert(value, "filter future onSuccess value invalid")
            expectationFilterFuture.fulfill()
        }
        filter.onFailure {error in
            XCTAssert(false, "filter future onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFilter() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationFilter = expectationWithDescription("fullfilled for filter")
        let expectationFilterFuture = expectationWithDescription("onFailure fullfilled for filtered future")
        let expectation = expectationWithDescription("onSuccess fullfilled")
        future.onSuccess {value in
            XCTAssertFalse(value, "future onSucces value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let filter = future.withFilter {value in
            expectationFilter.fulfill()
            return value
        }
        filter.onSuccess {value in
            XCTAssert(false, "filter future onSuccess called")
        }
        filter.onFailure {error in
            XCTAssertEqual(error.domain, "Wrappers", "filter future onFailure invalid error domain")
            XCTAssertEqual(error.code, 1, "filter future onFailure invalid error code")
            expectationFilterFuture.fulfill()
        }
        promise.success(false)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFuture() {
        let promise = Promise<Bool>()
        let future = promise.future
        let expectationFilterFuture = expectationWithDescription("onFailure fullfilled for filtered future")
        let expectation = expectationWithDescription("onSuccess fullfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let filter = future.withFilter {value in
            XCTAssert(false, "filter called")
            return value
        }
        filter.onSuccess {value in
            XCTAssert(false, "filter future onSuccess called")
        }
        filter.onFailure {error in
            XCTAssertEqual(error.domain, "SimpleFutures Tests", "filter future onFailure invalid error domain")
            XCTAssertEqual(error.code, 100, "filter future onFailure invalid error code")
            expectationFilterFuture.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
