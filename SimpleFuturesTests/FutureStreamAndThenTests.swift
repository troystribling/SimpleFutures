//
//  FutureStreamAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamAndThenTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulAndThen() {
        var countAndThen = 0
        var countAndThenOnSuccess = 0
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let expectationAndThen = expectationWithDescription("andThen handler fulfilled")
        let expectationAndThenOnSuccess = expectationWithDescription("OnSuccess fulfilled for andThen future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        stream.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let andThen = stream.andThen {result in
            switch result {
            case .Success(let resultBox):
                ++countAndThen
                if countAndThen == 2 {
                    expectationAndThen.fulfill()
                } else if countAndThen > 2 {
                    XCTAssert(false, "andThen called more than 2 times")
                }
            case .Failure(let error):
                XCTAssert(false, "andThen Failure")
            }
        }
        andThen.onSuccess {value in
            XCTAssert(value, "andThen onSuccess value invalid")
            ++countAndThenOnSuccess
            if countAndThenOnSuccess == 2 {
                expectationAndThenOnSuccess.fulfill()
            } else if countAndThenOnSuccess > 2 {
                XCTAssert(false, "andThen onSuccess called more than 2 times")
            }
        }
        andThen.onFailure {error in
            XCTAssert(false, "andThen onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedAndThen() {
        var countAndThen = 0
        var countAndThenOnSuccess = 0
        var count = 0
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let expectationAndThen = expectationWithDescription("andThen handler fulfilled")
        let expectationAndThenOnSuccess = expectationWithDescription("OnSuccess fulfilled for andThen future")
        let expectation = expectationWithDescription("OnFailure fulfilled")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        let andThen = stream.andThen {result in
            switch result {
            case .Success(let resultBox):
                XCTAssert(false, "andThen Success")
            case .Failure(let error):
                ++countAndThen
                if countAndThen == 2 {
                    expectationAndThen.fulfill()
                } else if countAndThen > 2 {
                    XCTAssert(false, "andThen called more than 2 times")
                }
            }
        }
        andThen.onSuccess {value in
            XCTAssert(false, "andThen onSuccess called")
        }
        andThen.onFailure {error in
            ++countAndThenOnSuccess
            if countAndThenOnSuccess == 2 {
                expectationAndThenOnSuccess.fulfill()
            } else if countAndThenOnSuccess > 2 {
                XCTAssert(false, "andThen onFailure called more than 2 times")
            }
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
