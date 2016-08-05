//
//  StreamCapacityTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamCapacityTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testOnSuccess_WithInfiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
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
        XCTAssertEqual(future.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithInfiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
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
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(future.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithFiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>(capacity: 2)
        var onSuccessCalled = 0
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
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
        XCTAssertEqual(future.count, 2)
        XCTAssertEqual(onSuccessCalled, 2)
    }

    func testOnSuccess_WithFiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>(capacity: 2)
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
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(future.count, 2)
        XCTAssertEqual(onSuccessCalled, 10)
    }

}
