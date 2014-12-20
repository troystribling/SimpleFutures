//
//  FutureStreamFlatmapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamFlatmapTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulMapping() {
        var count = 0
        var countMapped = 0
        let stream = FutureStream<Bool>()
        let expectationMapped = expectationWithDescription("OnSuccess fulfilled for mapped future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            let future = Future<Int>()
            future.success(1)
            return future
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            ++countMapped
            if countMapped == 2 {
                expectationMapped.fulfill()
            } else if countMapped > 2 {
                XCTAssert(false, "mapped onSuccess called more than 2 times")
            }
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped onFailure called")
        }
        writeSuccesfulFutures(stream, true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedMapping() {
        var count = 0
        var countMapped = 0
        let stream = FutureStream<Bool>()
        let expectationMapped = expectationWithDescription("OnSuccess fulfilled for mapped future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            let future = Future<Int>()
            future.failure(TestFailure.error)
            return future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            ++countMapped
            if countMapped == 2 {
                expectationMapped.fulfill()
            } else if countMapped > 2 {
                XCTAssert(false, "mapped onFailure called more than 2 times")
            }
        }
        writeSuccesfulFutures(stream, true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testMappingToFailedFuture() {
        var count = 0
        var countMapped = 0
        let stream = FutureStream<Bool>()
        let expectationMapped = expectationWithDescription("OnSuccess fulfilled for mapped future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onFailure called more than 2 times")
            }
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            XCTAssert(false, "flatmap called")
            let future = Future<Int>()
            future.failure(TestFailure.error)
            return future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            ++countMapped
            if countMapped == 2 {
                expectationMapped.fulfill()
            } else if countMapped > 2 {
                XCTAssert(false, "mapped onFailure called more than 2 times")
            }
        }
        writeFailedFutures(stream)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
