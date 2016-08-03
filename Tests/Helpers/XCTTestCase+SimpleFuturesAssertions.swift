//
//  XCTTestCase+SimpleFutures.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 5/5/16.
//  Copyright © 2016 Troy Stribling. All rights reserved.
//

import Foundation
import XCTest
import SimpleFutures

func XCTAssertFutureSucceeds<T>(future: Future<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0,
                             line: UInt = #line, file: String = #file, validate: ((T) -> Void)? = nil) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    var onSuccessCalled = false
    if context is QueueContext {
        expectation = currentTest.expectationWithDescription("onSuccess expectation failed")
    }
    future.onSuccess(context: context) { result in
        onSuccessCalled = true
        expectation?.fulfill()
        validate?(result)
    }
    future.onFailure(context: context) { _ in
        XCTFail("onFailure called")
    }
    if context is QueueContext {
        currentTest.waitForExpectationsWithTimeout(timeout) { error in
            if error != nil {
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            } else {
                if !onSuccessCalled {
                    currentTest.recordFailureWithDescription("onSuccess not called", inFile: file, atLine: line, expected: true)
                }
            }
        }
    } else {
        if !onSuccessCalled {
            currentTest.recordFailureWithDescription("onSuccess not called", inFile: file, atLine: line, expected: true)
        }
    }
}

func XCTAssertFutureStreamSucceeds<T>(stream: FutureStream<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validations: [((T) -> Void)] = []) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    let maxCount = validations.count
    var count = 0
    if context is QueueContext {
        expectation = currentTest.expectationWithDescription("onSuccess expectation failed")
    }
    stream.onSuccess(context: context) { result in
        count += 1
        if maxCount == 0 {
            expectation?.fulfill()
        } else if count > maxCount {
            XCTFail("onSuccess called more than \(maxCount) times")
        } else {
            validations[count - 1](result)
            if count == maxCount {
                expectation?.fulfill()
            }
        }
    }
    stream.onFailure(context: context) { _ in
        XCTFail("onFailure called")
    }
    if context is QueueContext {
        currentTest.waitForExpectationsWithTimeout(timeout) { error in
            if error == nil {
                if maxCount == 0 {
                    // no validations given onSuccess only called one time
                    if count != 1 {
                        currentTest.recordFailureWithDescription("onSuccess not called", inFile: file, atLine: line, expected: true)
                    }
                } else {
                    // validations given onSuccess called for each validation
                    if maxCount != count {
                        let message = "onSuccess not called \(maxCount) times"
                        currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
                    }
                }
            } else {
                // expectation not filfilled
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            }
        }
    } else {
        if maxCount == 0 {
            // no validations given onSuccess only called one time
            if count != 1 {
                currentTest.recordFailureWithDescription("onSuccess not called", inFile: file, atLine: line, expected: true)
            }
        } else {
            // validations given onSuccess called once for each validation
            if maxCount != count {
                currentTest.recordFailureWithDescription("onSuccess not called \(maxCount) times", inFile: file, atLine: line, expected: true)
            }
        }
    }
}


func XCTAssertFutureFails<T>(future: Future<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validate: (ErrorType -> Void)? = nil) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    var onFailureCalled = false
    if context is QueueContext {
        expectation = currentTest.expectationWithDescription("onSuccess expectation failed")
    }
    future.onSuccess(context: context) { _ in
        XCTFail("onSuccess called")
    }
    future.onFailure(context: context) { error in
        onFailureCalled = true
        expectation?.fulfill()
        validate?(error)
    }
    if context is QueueContext {
        currentTest.waitForExpectationsWithTimeout(timeout) { error in
            if error != nil {
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            } else {
                if !onFailureCalled {
                    currentTest.recordFailureWithDescription("onFailure not called", inFile: file, atLine: line, expected: true)
                }
            }
        }
    } else {
        if !onFailureCalled {
            currentTest.recordFailureWithDescription("onFailure not called", inFile: file, atLine: line, expected: true)
        }
    }
}

func XCTAssertFutureStreamFails<T>(stream: FutureStream<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validations: [(ErrorType -> Void)] = []) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    let maxCount = validations.count
    var count = 0
    if context is QueueContext {
        expectation = currentTest.expectationWithDescription("onSuccess expectation failed")
    }
    stream.onSuccess(context: context) { _ in
        XCTFail("onFailure called")
    }
    stream.onFailure(context: context) { error in
        count += 1
        if maxCount == 0 {
            expectation?.fulfill()
        } else if count > maxCount {
            XCTFail("onFailure called more than maxCount \(maxCount) times")
        } else {
            validations[count - 1](error)
            if count == maxCount {
                expectation?.fulfill()
            }
        }
    }
    if context is QueueContext {
        currentTest.waitForExpectationsWithTimeout(timeout) { error in
            if error == nil {
                if maxCount == 0 {
                    // no validations given onFailure only called one time
                    if count != 1 {
                        currentTest.recordFailureWithDescription("onFailure not called", inFile: file, atLine: line, expected: true)
                    }
                } else {
                    // validations given onFailure called once for each validation
                    if maxCount != count {
                        let message = "onFailure not called \(maxCount) times"
                        currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
                    }
                }
            } else {
                // expectation not fulfilled
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            }
        }
    } else {
        if maxCount == 0 {
            // no validations given onFailure only called one time
            if count != 1 {
                currentTest.recordFailureWithDescription("onFailure not called", inFile: file, atLine: line, expected: true)
            }
        } else {
            // validations given onFailure called once for each validation
            if maxCount != count {
                currentTest.recordFailureWithDescription("onFailure not called \(maxCount) times", inFile: file, atLine: line, expected: true)
            }
        }
    }
}

func XCTExpectFullfilledCountTimes(maxCount:Int, message:String) -> Void -> Void {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    let expectation = currentTest.expectationWithDescription("\(message) fulfilled")
    var count = 0
    return {
        count += 1
        if count == maxCount {
            expectation.fulfill()
        } else if count > maxCount {
            XCTAssert(false, "\(message) called more than \(maxCount) times")
        }
    }
}

func XCTAssertEqualErrors(error1: ErrorType, _ error2: ErrorType, line: UInt = #line, file: StaticString = #file) {
    XCTAssertEqual(error1._domain, error2._domain, line: line, file: file, "invalid error domain")
    XCTAssertEqual(error1._code, error2._code, line: line, file: file, "invalid error code")
}
