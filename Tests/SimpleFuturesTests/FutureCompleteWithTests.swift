//
//  FutureCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/25/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureCompleteWithTests: XCTestCase {

    let immediateContext = ImmediateContext()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCompletesWith_WhenDependentFutureCompletedFirst_CompletesSuccessfully() {
        let future = Future<Bool>()
        let futureCompleted = Future<Bool>()

        var onSuccessCalled = false
        var completedOnSuccessCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssert(value, "future onSuccess value invalid")
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail("onFailure called")
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value, "futureCompleted onSuccess value invalid")
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail("onFailure called")
        }

        futureCompleted.success(true)
        future.completeWith(context: TestContext.immediate, future: futureCompleted)

        XCTAssert(onSuccessCalled, "onSuccess not called")
        XCTAssert(completedOnSuccessCalled, "onSuccess not called")
    }

    func testCompletesWith_WhenDependentFutureCompletedLast_CompletesSuccessfully() {
        let future = Future<Bool>()
        let futureCompleted = Future<Bool>()

        var onSuccessCalled = false
        var completedOnSuccessCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssert(value, "future onSuccess value invalid")
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail("onFailure called")
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value, "futureCompleted onSuccess value invalid")
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail("onFailure called")
        }

        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.success(true)

        XCTAssert(onSuccessCalled, "onSuccess not called")
        XCTAssert(completedOnSuccessCalled, "onSuccess not called")
    }

    func testCompletesWith_WhenDependentFutureFails_CompletesWithEnclosingFutureError() {
        let future = Future<Bool>()
        let futureCompleted =  Future<Bool>()

        var onFailureCalled = false
        var completedOnFailureCalled = false


        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail("future onSuccess called")
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)

        }
        futureCompleted.onSuccess(context: TestContext.immediate) {  value in
            XCTAssert(false, "futureCompleted onSuccess called")
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            completedOnFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.failure(TestFailure.error)

        XCTAssert(onFailureCalled, "onFailure not called")
        XCTAssert(completedOnFailureCalled, "onFailure not called")

    }
    
}

