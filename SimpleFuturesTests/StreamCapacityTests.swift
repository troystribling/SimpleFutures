//
//  StreamCapacityTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import SimpleFutures

class StreamCapacityTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInfinteCapacityDealyed() {
        let promise = StreamPromise<Bool>()
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(10, message:"onSuccess future")
        future.onSuccess {value in
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, true, 10)
        XCTAssertEqual(future.count, 10, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testInfinteCapacityImmediate() {
        let promise = StreamPromise<Bool>()
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(10, message:"onSuccess future")
        writeSuccesfulFutures(promise, true, 10)
        future.onSuccess {value in
            onSuccessExpectation()
        }
        XCTAssertEqual(future.count, 10, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCacapcitDelayed() {
        let promise = StreamPromise<Int>(capacity:2)
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(10, message:"onSuccess future")
        future.onSuccess {value in
            XCTAssert(contains(Array(1...10), value), "onSuccess invalid value")
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, Array(1...10))
        XCTAssertEqual(future.count, 2, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testCacapcitImmediate() {
        let promise = StreamPromise<Int>(capacity:2)
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        writeSuccesfulFutures(promise, Array(1...10))
        future.onSuccess {value in
            XCTAssert(value == 9 || value == 10, "onSuccess invalid value")
            onSuccessExpectation()
        }
        XCTAssertEqual(future.count, 2, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
