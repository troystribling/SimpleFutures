//
//  FutureForeachTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureForeachTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccess() {
        let promise = Promise<Bool>()
        let future = promise.future
        let foreachExpectation = expectationWithDescription("foreach fulfilled")
        let onSuccessExpectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        future.foreach {value in
            XCTAssert(value, "foreach valus invalid")
            foreachExpectation.fulfill()
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailure() {
        let promise = Promise<Bool>()
        let future = promise.future
        let onFailureExpectation = expectationWithDescription("OnFailure fulfilled")
        future.onSuccess {value in
            XCTAssert(false, "future onSucces called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        future.foreach {value in
            XCTAssert(false, "foreach called")
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
