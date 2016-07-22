//
//  Future0NFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureOnFailureTests: XCTestCase {

    let immediateContext = ImmediateContext()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnFailure_CompletedBeforeCallbacksDefined_CompletesWithError() {
        let promise = Promise<Bool>()
        let future = promise.future
        promise.failure(TestFailure.error)
        XCTAssertFutureFails(future, context: immediateContext) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }
    
    func testOnFailure_CompletedAfterCallbacksDefined_CompletesWithError() {
        let promise = Promise<Bool>()
        var onFailureCalled = false
        let future = promise.future
        future.onSuccess(immediateContext) {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure(immediateContext) {error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
       promise.failure(TestFailure.error)
        XCTAssertTrue(onFailureCalled)
    }
    
    func testOnFailure_WithCallbacksDefinedBothBeforeAndAfterCompletion_CompletesWithError() {
        let promise = Promise<Bool>()
        let future = promise.future
        var onFailure1Called = false
        var onFailure2Called = false
        future.onSuccess(immediateContext) { value in
            XCTAssert(false, "Delayed onSuccess called")
        }
        future.onFailure(immediateContext) { error in
            onFailure1Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        XCTAssertFalse(onFailure1Called)
        promise.failure(TestFailure.error)
        future.onSuccess(immediateContext) { value in
            XCTAssert(false, "Immediate onSuccess called")
        }
        future.onFailure(immediateContext) { error in
            onFailure2Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        XCTAssertTrue(onFailure1Called)
        XCTAssertTrue(onFailure2Called)
    }
    
}

