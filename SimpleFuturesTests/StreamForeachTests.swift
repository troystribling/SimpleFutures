//
//  StreamForeachTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamForeachTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccess() {
        let promise = StreamPromise<Int>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let foreachExpectation = fulfillAfterCalled(2, message:"foreach")
        stream.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "stream onSuccess invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        stream.foreach {value in
            XCTAssert(value == 1 || value == 2, "stream foreach invalid value")
            foreachExpectation()
        }
        writeSuccesfulFutures(promise, [1,2])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailure() {
        let promise = StreamPromise<Int>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        stream.foreach {value in
            XCTAssert(false, "foreach called")
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
