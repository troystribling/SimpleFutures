//
//  FutureStreamWithFilter.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/23/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamWithFilter: XCTestCase {

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
        stream.onSuccess {value in
            XCTAssert(value, "filter future onSuccess value invalid")
            onSuccessFilterExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "filter future onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFilter() {
    }
    
    func testFailedFuture() {
    }

}
