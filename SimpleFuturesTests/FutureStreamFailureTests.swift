//
//  FutureStreamFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamFailureTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWriteImmediate() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        writeFailedFutures(stream, 2)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        stream.onFailure {error in
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onFailure called more than 2 times")
            }
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteDelayed() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        stream.onFailure {error in
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onFailure called more than 2 times")
            }
        }
        writeFailedFutures(stream, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteDelayedAndImmediate() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        writeFailedFutures(stream, 1)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        writeFailedFutures(stream, 1)
        stream.onFailure {error in
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onFailure called more than 2 times")
            }
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testStreamPromise() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        promise.future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        promise.future.onFailure {error in
            ++count
            if count == 1 {
                expectation.fulfill()
            } else if count > 1 {
                XCTAssert(false, "onFailure called more than 2 times")
            }
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }

    }

    func testWtiteUncompletedFuture() {
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        let f = Future<Bool>()
        stream.write(f)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        stream.onFailure {error in
            expectation.fulfill()
            XCTAssert(error.code == 2, "onFailure error invalid")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}