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
        let promise = StreamPromise<Bool>()
        let future = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(10, message:"onSuccess future")
        writeSuccesfulFutures(promise, value:true, times:10)
        future.onSuccess {value in
            onSuccessExpectation()
        }
        XCTAssertEqual(future.count, 10, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testOnSuccess_WithInfiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let promise = StreamPromise<Bool>()
        let future = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(10, message:"onSuccess future")
        future.onSuccess {value in
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, value:true, times:10)
        XCTAssertEqual(future.count, 10, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testOnSuccess_WithFiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let promise = StreamPromise<Int>(capacity:2)
        let future = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        writeSuccesfulFutures(promise, values:Array(1...10))
        future.onSuccess {value in
            XCTAssert(value == 9 || value == 10, "onSuccess invalid value")
            onSuccessExpectation()
        }
        XCTAssertEqual(future.count, 2, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testOnSuccess_WithFiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let promise = StreamPromise<Int>(capacity:2)
        let future = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(10, message:"onSuccess future")
        future.onSuccess {value in
            XCTAssert(Array(1...10).contains(value), "onSuccess invalid value")
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, values:Array(1...10))
        XCTAssertEqual(future.count, 2, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
