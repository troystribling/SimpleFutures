//
//  StreamForeachTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamForeachTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccess() {
        let promise = StreamPromise<Int>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let foreachExpectation = XCTExpectFullfilledCountTimes(2, message:"forEach")
        stream.onSuccess {value in
            XCTAssert(value == 1 || value == 2, "stream onSuccess invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        stream.forEach {value in
            XCTAssert(value == 1 || value == 2, "stream forEach invalid value")
            foreachExpectation()
        }
        writeSuccesfulFutures(promise, values:[1,2])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailure() {
        let promise = StreamPromise<Int>()
        let stream = promise.stream
        let onFailureExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        stream.forEach {value in
            XCTAssert(false, "forEach called")
        }
        writeFailedFutures(promise, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
