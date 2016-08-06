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
        let stream = FutureStream<Bool>()
        var onSuccessCalled = 0
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(stream.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithInfiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>()
        var onSuccessCalled = 0
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        XCTAssertEqual(stream.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithFiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>(capacity: 2)
        var onSuccessCalled = 0
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(stream.count, 2)
        XCTAssertEqual(onSuccessCalled, 2)
    }

    func testOnSuccess_WithFiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>(capacity: 2)
        var onSuccessCalled = 0
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        XCTAssertEqual(stream.count, 2)
        XCTAssertEqual(onSuccessCalled, 10)
    }

}
