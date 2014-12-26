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
    
    func testImmediate() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        writeFailedFutures(promise, 2)
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
    
    func testDelayed() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
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
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayedAndImmediate() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        writeFailedFutures(promise, 1)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        writeFailedFutures(promise, 1)
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
    
}