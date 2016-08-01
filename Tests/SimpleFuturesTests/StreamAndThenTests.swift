//
//  StreamAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamAndThenTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulAndThen() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let andThenExpectation = XCTExpectFullfilledCountTimes(2, message:"andThen")
        let onSuccessAndThenExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess andThen future")
        stream.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTFail("future onFailure called")
        }
        let andThen = stream.andThen { _ in
            andThenExpectation()
        }
        andThen.onSuccess {value in
            XCTAssert(value, "andThen onSuccess value invalid")
            onSuccessAndThenExpectation()
        }
        andThen.onFailure {error in
            XCTAssert(false, "andThen onFailure called")
        }
        writeSuccesfulFutures(promise, value:true, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailedAndThen() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onFailureAndThenExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure andThen future")
        let andThen = stream.andThen {result in
            XCTFail("andThen called")
        }
        andThen.onFailure {error in
            onFailureAndThenExpectation()
        }
        writeFailedFutures(promise, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}