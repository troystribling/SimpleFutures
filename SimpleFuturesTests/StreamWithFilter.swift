//
//  StreamWithFilter.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/23/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import SimpleFutures

class StreamWithFilter: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulFilter() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let withFilterExpectation = fulfillAfterCalled(2, message:"withFilter")
        let onSuccessFilterExpectation = fulfillAfterCalled(2, message:"onSuccess filter future")
        stream.onSuccess {value in
            XCTAssert(value, "future onSucces value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let filter = stream.withFilter {value in
            withFilterExpectation()
            return value
        }
        filter.onSuccess {value in
            XCTAssert(value, "filter future onSuccess value invalid")
            onSuccessFilterExpectation()
        }
        filter.onFailure {error in
            XCTAssert(false, "filter future onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFilter() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let withFilterExpectation = fulfillAfterCalled(2, message:"withFilter")
        let onFailureFilterExpectation = fulfillAfterCalled(2, message:"onFailure filter future")
        stream.onSuccess {value in
            XCTAssert(!value, "future onSucces value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let filter = stream.withFilter {value in
            withFilterExpectation()
            return value
        }
        filter.onSuccess {value in
            XCTAssert(false, "filter future onSuccess called")
        }
        filter.onFailure {error in
            XCTAssertEqual(error.domain, "Wrappers", "filter future onFailure invalid error domain")
            XCTAssertEqual(error.code, 1, "filter future onFailure invalid error code")
            onFailureFilterExpectation()
        }
        writeSuccesfulFutures(promise, false, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFuture() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        let onFailureFilterExpectation = fulfillAfterCalled(2, message:"onFailure filter future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSucces called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        let filter = stream.withFilter {value in
            return value
        }
        filter.onSuccess {value in
            XCTAssert(false, "filter future onSuccess called")
        }
        filter.onFailure {error in
            XCTAssertEqual(error.domain, "SimpleFutures Tests", "filter future onFailure invalid error domain")
            XCTAssertEqual(error.code, 100, "filter future onFailure invalid error code")
            onFailureFilterExpectation()
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
