//
//  FutureOnSuccessTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 12/14/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureOnSuccessTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnSuccess_WhenCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled = false
        future.success(true)
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertTrue(onSuccessCalled)
    }
    
    func testOnSuccess_WhenCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled = false
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        XCTAssertTrue(onSuccessCalled)
    }

    func testOnSuccess_WhenCompletedWithMultipleCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled1 = false
        var onSuccessCalled2 = false
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled1 = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled2 = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        XCTAssertTrue(onSuccessCalled1)
        XCTAssertTrue(onSuccessCalled2)
    }

}

    