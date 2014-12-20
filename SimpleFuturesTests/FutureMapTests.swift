//
//  FutureMapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureMapTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessfulMapping() {
        let future = Future<Bool>()
        let expectationMapped = expectationWithDescription("OnSuccess fulfilled for mapped future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = future.map {value -> Try<Int> in
            return Try(Int(1))
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            expectationMapped.fulfill()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedMapping() {
        let future = Future<Bool>()
        let expectationMapped = expectationWithDescription("OnFailure fulfilled for mapped future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = future.map {value -> Try<Int> in
            return Try<Int>(TestFailure.error)
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            expectationMapped.fulfill()
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testMappingToFailedFuture() {
        let future = Future<Bool>()
        let expectationMapped = expectationWithDescription("OnFailure fulfilled for mapped future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSucces called")
        }
        future.onFailure {error in
            expectation.fulfill()
        }
        let mapped = future.map {value -> Try<Int> in
            XCTAssert(false, "map called")
            return Try(Int(1))
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            expectationMapped.fulfill()
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
