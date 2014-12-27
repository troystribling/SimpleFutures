//
//  StreamFlatmapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamFlatmapTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulMapping() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let flatmapExpectation = fulfillAfterCalled(2, message:"flatmap")
        let onSuccessMappedExpectation = fulfillAfterCalled(2, message:"onSuccess mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            flatmapExpectation()
            let promise = Promise<Int>()
            promise.success(1)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            onSuccessMappedExpectation()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedMapping() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let flatmapExpectation = fulfillAfterCalled(2, message:"flatmap")
        let onFailureMappedExpectation = fulfillAfterCalled(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            flatmapExpectation()
            let promise = Promise<Int>()
            promise.failure(TestFailure.error)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testMappingToFailedFuture() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        let onFailureMappedExpectation = fulfillAfterCalled(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        let mapped = stream.flatmap {value -> Future<Int> in
            XCTAssert(false, "flatmap called")
            let promise = Promise<Int>()
            promise.failure(TestFailure.error)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testSuccessfulMappingToFutureStrean() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let flatmapExpectation = fulfillAfterCalled(2, message:"flatmap")
        let onSuccessMappedExpectation = fulfillAfterCalled(4, message:"onSuccess mapped future")
        stream.onSuccess {value in
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatmap {value -> FutureStream<Int> in
            flatmapExpectation()
            let promise = StreamPromise<Int>()
            if value {
                writeSuccesfulFutures(promise, [1, 2])
            } else {
                writeSuccesfulFutures(promise, [3, 4])
            }
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssert(value == 1 || value == 2 || value == 3 || value == 4, "mapped onSuccess value invalid")
            onSuccessMappedExpectation()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped onFailure called")
        }
        writeSuccesfulFutures(promise, [true, false])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
