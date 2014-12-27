//
//  StreamCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/26/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamCompleteWithTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessImmediate() {
        let promise = StreamPromise<Int>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        writeSuccesfulFutures(promiseCompleted, [1,2])
        stream.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "completed onSuccess value invalid")
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
        let promise = StreamPromise<Int>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        stream.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "onSuccess value invalid")
            onSuccessCompletedExpectation()
        }
        streamCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        promise.completeWith(streamCompleted)
        writeSuccesfulFutures(promiseCompleted, [1,2])
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
        let promise = StreamPromise<Int>()
        let stream = promise.future
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.future
        let onSuccessExpectation = fulfillAfterCalled(4, message:"onSuccess future")
        let onSuccessCompletedExpectation = fulfillAfterCalled(2, message:"onSuccess completed future")
        stream.onSuccess {value in
            XCTAssert(value == 1 || value == 2 || value == 3 || value == 4, "onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        streamCompleted.onSuccess {value in
            XCTAssert(value == 3 || value == 4, "onSuccess value invalid")
            onSuccessCompletedExpectation()
        }
        streamCompleted.onFailure{error in
            XCTAssert(false, "futureComleted onFailure called")
        }
        writeSuccesfulFutures(promise, [1,2])
        promise.completeWith(streamCompleted)
        writeSuccesfulFutures(promiseCompleted, [3,4])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
