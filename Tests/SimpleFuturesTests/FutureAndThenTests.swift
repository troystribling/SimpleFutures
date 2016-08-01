//
//  FutureAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureAndThenTests : XCTestCase {

    let immediateContext = ImmediateContext()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAndThen_FollowingSuccessfulFuture_CompletesSuccessfully() {
        var successCalled = false
        let promise = Promise<Bool>()
        let future = promise.future
        let andThen = future.andThen(context: TestContext.immediate) { value in
            successCalled = true
        }
        promise.success(true)
        XCTAssert(successCalled, "andThen .Success not called")
        XCTAssertFutureSucceeds(andThen, context: self.immediateContext) { value in
            XCTAssert(value, "andThen onSuccess value invalid")
        }
    }

    func testAndThen_FollowingFailedFuture_CompletesWithError() {
        let promise = Promise<Bool>()
        let future = promise.future
        let andThen = future.andThen(context: TestContext.immediate) { _ in
            XCTAssert(false, "andThen Failure")
        }
        promise.failure(TestFailure.error)
        XCTAssertFutureFails(andThen, context: self.immediateContext) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }
    
}