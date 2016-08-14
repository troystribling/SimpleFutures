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

func XCTAssertFutureSucceeds<T>(_ future: Future<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0,
                             line: UInt = #line, file: String = #file, validate: ((T) -> Void)? = nil) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    var onSuccessCalled = false
    if context is QueueContext {
        expectation = currentTest.expectation(description: "onSuccess expectation failed")
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
        currentTest.waitForExpectations(timeout: timeout) { error in
            if error != nil {
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            } else {
                if !onSuccessCalled {
                    currentTest.recordFailure(withDescription: "onSuccess not called", inFile: file, atLine: line, expected: true)
                }
            }
        }
    } else {
        if !onSuccessCalled {
            currentTest.recordFailure(withDescription: "onSuccess not called", inFile: file, atLine: line, expected: true)
        }
    }
}

func XCTAssertFutureStreamSucceeds<T>(_ stream: FutureStream<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validations: [((T) -> Void)] = []) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    let maxCount = validations.count
    var count = 0
    if context is QueueContext {
        expectation = currentTest.expectation(description: "onSuccess expectation failed")
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
        currentTest.waitForExpectations(timeout: timeout) { error in
            if error == nil {
                if maxCount == 0 {
                    // no validations given onSuccess only called one time
                    if count != 1 {
                        currentTest.recordFailure(withDescription: "onSuccess not called", inFile: file, atLine: line, expected: true)
                    }
                } else {
                    // validations given onSuccess called for each validation
                    if maxCount != count {
                        let message = "onSuccess not called \(maxCount) times"
                        currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
                    }
                }
            } else {
                // expectation not filfilled
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    } else {
        if maxCount == 0 {
            // no validations given onSuccess only called one time
            if count != 1 {
                currentTest.recordFailure(withDescription: "onSuccess not called", inFile: file, atLine: line, expected: true)
            }
        } else {
            // validations given onSuccess called once for each validation
            if maxCount != count {
                currentTest.recordFailure(withDescription: "onSuccess not called \(maxCount) times", inFile: file, atLine: line, expected: true)
            }
        }
    }
}


func XCTAssertFutureFails<T>(_ future: Future<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validate: ((Swift.Error) -> Void)? = nil) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    var onFailureCalled = false
    if context is QueueContext {
        expectation = currentTest.expectation(description: "onSuccess expectation failed")
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
        currentTest.waitForExpectations(timeout: timeout) { error in
            if error != nil {
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            } else {
                if !onFailureCalled {
                    currentTest.recordFailure(withDescription: "onFailure not called", inFile: file, atLine: line, expected: true)
                }
            }
        }
    } else {
        if !onFailureCalled {
            currentTest.recordFailure(withDescription: "onFailure not called", inFile: file, atLine: line, expected: true)
        }
    }
}

func XCTAssertFutureStreamFails<T>(_ stream: FutureStream<T>, context: ExecutionContext = QueueContext.main, timeout: Double = 10.0, line: UInt = #line, file: String = #file, validations: [((Swift.Error) -> Void)] = []) {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    var expectation: XCTestExpectation?
    let maxCount = validations.count
    var count = 0
    if context is QueueContext {
        expectation = currentTest.expectation(description: "onSuccess expectation failed")
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
        currentTest.waitForExpectations(timeout: timeout) { error in
            if error == nil {
                if maxCount == 0 {
                    // no validations given onFailure only called one time
                    if count != 1 {
                        currentTest.recordFailure(withDescription: "onFailure not called", inFile: file, atLine: line, expected: true)
                    }
                } else {
                    // validations given onFailure called once for each validation
                    if maxCount != count {
                        let message = "onFailure not called \(maxCount) times"
                        currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
                    }
                }
            } else {
                // expectation not fulfilled
                let message = "Failed to meet expectation after \(timeout)s"
                currentTest.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    } else {
        if maxCount == 0 {
            // no validations given onFailure only called one time
            if count != 1 {
                currentTest.recordFailure(withDescription: "onFailure not called", inFile: file, atLine: line, expected: true)
            }
        } else {
            // validations given onFailure called once for each validation
            if maxCount != count {
                currentTest.recordFailure(withDescription: "onFailure not called \(maxCount) times", inFile: file, atLine: line, expected: true)
            }
        }
    }
}

func XCTExpectFullfilledCountTimes(_ maxCount:Int, message:String) -> (Void) -> Void {

    guard let currentTest = _XCTCurrentTestCase() else { fatalError("XCTGuardAssert attempted without a running test.") }

    let expectation = currentTest.expectation(description: "\(message) fulfilled")
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

func XCTAssertEqualErrors(_ error1: Swift.Error, _ error2: Swift.Error, line: UInt = #line, file: StaticString = #file) {
    XCTAssertEqual(error1._domain, error2._domain, "invalid error code")
    XCTAssertEqual(error1._code, error2._code, "invalid error code")
}
