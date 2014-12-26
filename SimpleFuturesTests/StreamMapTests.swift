//
//  StreamMapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamMapTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulMapping() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccess = fulfillAfterCalled(2, message:"onSuccess future")
        let map = fulfillAfterCalled(2, message:"map")
        let onSuccessMapped = fulfillAfterCalled(2, message:"onSuccess mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.map {value -> Try<Int> in
            map()
            return Try(Int(1))
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            onSuccessMapped()
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
        let onSuccess = fulfillAfterCalled(2, message:"onSuccess future")
        let map = fulfillAfterCalled(2, message:"map")
        let onFailureMapped = fulfillAfterCalled(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccess()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.map {value -> Try<Int> in
            map()
            return Try<Int>(TestFailure.error)
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMapped()
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testMappingToFailedFuture() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailure = fulfillAfterCalled(2, message:"onFailure future")
        let onFailureMapped = fulfillAfterCalled(2, message:"onFailure mapped future")

        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailure()
        }
        let mapped = stream.map {value -> Try<Int> in
            XCTAssert(false, "map called")
            return Try<Int>(TestFailure.error)
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMapped()
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
