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
        let onSuccess = fulfillAfterCalled(expectationWithDescription("onSuccess fulfilled for future stream"), 2, "onSuccess called more than 2 times")
        writeSuccesfulFutures(promise, true, 2)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
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
        let onSuccess = fulfillAfterCalled(expectationWithDescription("onSuccess fulfilled for future stream"), 2, "onSuccess called more than 2 times")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
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
        let onSuccess = fulfillAfterCalled(expectationWithDescription("onSuccess fulfilled for future stream"), 2, "onSuccess called more than 2 times")
        writeSuccesfulFutures(promise, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
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
        let onSuccessImmediate = fulfillAfterCalled(expectationWithDescription("onSuccess immediate fulfilled for future stream"), 2, "onSuccess immediate called more than 2 times")
        let onSuccessDelayed = fulfillAfterCalled(expectationWithDescription("onSuccess immediate fulfilled for future stream"), 2, "onSuccess delayed called more than 2 times")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessImmediate()
        }
        writeSuccesfulFutures(promise, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessDelayed()
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
        let onFailure = fulfillAfterCalled(expectationWithDescription("onFailure fulfilled for future stream"), 1, "onSuccess immediate called more than 2 times")
        let onSuccess = fulfillAfterCalled(expectationWithDescription("onSuccess fulfilled for future stream"), 1, "onSuccess immediate called more than 2 times")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
        }
        stream.onFailure {error in
            ++countFailure
            onFailure()
        }
        writeSuccesfulFutures(promise, true, 1)
        writeFailedFutures(promise, 1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}

