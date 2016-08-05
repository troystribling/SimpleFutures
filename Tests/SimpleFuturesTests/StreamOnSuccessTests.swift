//
//  StreamOnSuccessTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamOnSuccessTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnSuccess_WhenCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.success(true)
        future.success(true)
        future.success(true)
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(onSuccessCalled, 3)
    }
    
    func testOnSuccess_WhenCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled, 3)
    }

    func testOnSuccess_WhenCompletedBeforeAndAfterCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.success(true)
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled, 3)
    }
    
    func testOnSuccess_WhenCompletedWithMultipleCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled1 = 0
        var onSuccessCalled2 = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled1 += 1
            }
        }
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled2 += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled1, 3)
        XCTAssertEqual(onSuccessCalled2, 3)
    }
    
    func testOnSuccess_WhenCompletedWithSuccessAndFailure_CompletesSuccessfullyAndWithError() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        var onFailureCalled = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
            onFailureCalled += 1
        }
        future.success(true)
        future.success(true)
        future.success(true)
        future.failure(TestFailure.error)
        future.failure(TestFailure.error)
        future.failure(TestFailure.error)
        XCTAssertEqual(onSuccessCalled, 3)
        XCTAssertEqual(onFailureCalled, 3)
    }

}

