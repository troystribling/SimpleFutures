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
            XCTAssert(value)
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value)
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.success(true)
        future.completeWith(context: TestContext.immediate, future: futureCompleted)

        XCTAssert(onSuccessCalled)
        XCTAssert(completedOnSuccessCalled)
    }

    func testCompletesWith_WhenDependentFutureCompletedLast_CompletesSuccessfully() {
        let future = Future<Bool>()
        let futureCompleted = Future<Bool>()

        var onSuccessCalled = false
        var completedOnSuccessCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssert(value)
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value)
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.success(true)

        XCTAssert(onSuccessCalled)
        XCTAssert(completedOnSuccessCalled)
    }

    func testCompletesWith_WhenDependentFutureFails_CompletesWithEnclosingFutureError() {
        let future = Future<Bool>()
        let futureCompleted =  Future<Bool>()

        var onFailureCalled = false
        var completedOnFailureCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)

        }
        futureCompleted.onSuccess(context: TestContext.immediate) {  value in
            XCTFail()
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            completedOnFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        
        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.failure(TestFailure.error)

        XCTAssert(onFailureCalled)
        XCTAssert(completedOnFailureCalled)

    }
    
}

