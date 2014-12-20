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
        writeFailedFutures(stream)
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
        writeFailedFutures(stream)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteDelayedAndImmediate() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onFailure fulfilled for future stream")
        let f1 = Future<Bool>()
        f1.failure(TestFailure.error)
        stream.write(f1)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        let f2 = Future<Bool>()
        f2.failure(TestFailure.error)
        stream.write(f2)
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