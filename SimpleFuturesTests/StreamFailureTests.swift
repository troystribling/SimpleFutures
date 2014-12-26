//
//  StreamFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamFailureTests : XCTestCase {
    
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
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        writeFailedFutures(promise, 2)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
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
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        writeFailedFutures(promise, 1)
        stream.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        writeFailedFutures(promise, 1)
        stream.onFailure {error in
            onFailureExpectation()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}