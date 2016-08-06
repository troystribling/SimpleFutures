//
//  StreamCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/26/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamCompleteWithTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCompletesWith_WhenDependentFutureStreamCompletedFirst_CompletesSuccessfully() {
        let promise = StreamPromise<Int>()
        let stream = promise.stream
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess completed future")
        writeSuccesfulFutures(promiseCompleted, values:[1,2])
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
        promise.completeWith(stream: streamCompleted)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCompletesWith_WhenDependentFutureStreamCompletedLast_CompletesSuccessfully() {
        let promise = StreamPromise<Int>()
        let stream = promise.stream
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let onSuccessCompletedExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess completed future")
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
        promise.completeWith(stream: streamCompleted)
        writeSuccesfulFutures(promiseCompleted, values:[1,2])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCompletesWith_WhenDependentFutureStreamFails_CompletesWithDependantFutureError() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let promiseCompleted = StreamPromise<Bool>()
        let streamCompleted = promiseCompleted.stream
        let onFailureExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure future")
        let onFailureCompletedExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure completed future")
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
        promise.completeWith(stream: streamCompleted)
        writeFailedFutures(promiseCompleted, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCompletesWith_WhenDependentFutureCompletesBeforeAndAfterCompletion_CompletesSuccessfully() {
        let promise = StreamPromise<Int>()
        let stream = promise.stream
        let promiseCompleted = StreamPromise<Int>()
        let streamCompleted = promiseCompleted.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(4, message:"onSuccess future")
        let onSuccessCompletedExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess completed future")
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
        writeSuccesfulFutures(promise, values:[1,2])
        promise.completeWith(stream: streamCompleted)
        writeSuccesfulFutures(promiseCompleted, values:[3,4])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
