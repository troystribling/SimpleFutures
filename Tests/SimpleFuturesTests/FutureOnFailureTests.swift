//
//  FutureONFailureTests.swift
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
        let future = Future<Bool>()
        future.failure(TestFailure.error)
        XCTAssertFutureFails(future, context: immediateContext) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }
    
    func testOnFailure_CompletedAfterCallbacksDefined_CompletesWithError() {
        let future = Future<Bool>()
        var onFailureCalled = false
        future.onSuccess(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) {error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
       future.failure(TestFailure.error)
        XCTAssertTrue(onFailureCalled)
    }
    
    func testOnFailure_WithMultipleCallbacksDefined_CompletesWithError() {
        let future = Future<Bool>()
        var onFailure1Called = false
        var onFailure2Called = false
        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailure1Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailure2Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.failure(TestFailure.error)
        XCTAssertTrue(onFailure1Called)
        XCTAssertTrue(onFailure2Called)
    }
    
}

