//
//  FutureStreamSuccessTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamSuccessTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImmediate() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        writeSuccesfulFutures(promise, true, 2)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDelayedAndImmediate() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        writeSuccesfulFutures(promise, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, true, 1)
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testMultipleCallbacks() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        writeSuccesfulFutures(promise, true, 1)
        let onSuccessImmediateExpectation = fulfillAfterCalled(2, message:"onSuccess immediate future")
        let onSuccessDelayedExpectation = fulfillAfterCalled(2, message:"onSuccess delayed future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessImmediateExpectation()
        }
        writeSuccesfulFutures(promise, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessDelayedExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testSuccessAndFailure() {
        var countSuccess = 0
        var countFailure = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(1, message:"onFailure future")
        let onSuccessExpectation = fulfillAfterCalled(1, message:"onSuccess future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            ++countFailure
            onFailureExpectation()
        }
        writeSuccesfulFutures(promise, true, 1)
        writeFailedFutures(promise, 1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}

