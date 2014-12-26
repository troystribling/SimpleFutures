//
//  FutureStreamCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/25/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamCompleteWithTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessImmediate() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Bool>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        writeSuccesfulFutures(promiseCompleted, true, 2)
        stream.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value, "futureCompleted onSuccess value invalid")
            onSuccessCompletedExpectation()
        }
        streamCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        promise.completeWith(streamCompleted)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testSuccessDelayed() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Bool>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        stream.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value, "futureCompleted onSuccess value invalid")
            onSuccessCompletedExpectation()
        }
        streamCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        promise.completeWith(streamCompleted)
        writeSuccesfulFutures(promiseCompleted, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailure() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Bool>()
        let streamCompleted = promiseCompleted.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        let onFailureCompletedExpectation = fulfillAfterCalled(2, message:"onFailure completed future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        streamCompleted.onSuccess {value in
            XCTAssert(false, "futureCompleted onSuccess called")
        }
        streamCompleted.onFailure{error in
            onFailureCompletedExpectation()
        }
        promise.completeWith(streamCompleted)
        writeFailedFutures(promiseCompleted, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCompleted() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Bool>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        stream.onSuccess {value in
            XCTAssert(!value, "future onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value, "futureCompleted onSuccess value invalid")
            onSuccessCompletedExpectation()
        }
        streamCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        writeSuccesfulFutures(promise, false, 2)
        promise.completeWith(streamCompleted)
        writeSuccesfulFutures(promiseCompleted, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
