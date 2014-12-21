//
//  FutureStreamSuccessTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamSuccessTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWriteImmediate() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onSuccess fulfilled for future stream")
        writeSuccesfulFutures(stream, true, 2)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteDelayed() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onSuccess fulfilled for future stream")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        writeSuccesfulFutures(stream, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteDelayedAndImmediate() {
        var count = 0
        let stream = FutureStream<Bool>()
        let expectation = expectationWithDescription("onSuccess fulfilled for future stream")
        writeSuccesfulFutures(stream, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 2 {
                expectation.fulfill()
            } else if count > 2 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        writeSuccesfulFutures(stream, true, 1)
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testMultipleCallbacks() {
        var countImmediate = 0
        var countDelayed = 0
        let stream = FutureStream<Bool>()
        let expectationImmediate = expectationWithDescription("onSuccess immediate fulfilled for future stream")
        let expectationDelayed = expectationWithDescription("onSuccess delayed fulfilled for future stream")
        writeSuccesfulFutures(stream, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++countImmediate
            if countImmediate == 2 {
                expectationImmediate.fulfill()
            } else if countImmediate > 2 {
                XCTAssert(false, "onSuccess immediate called more than 2 times")
            }
        }
        writeSuccesfulFutures(stream, true, 1)
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++countDelayed
            if countDelayed == 2 {
                expectationDelayed.fulfill()
            } else if countDelayed > 2 {
                XCTAssert(false, "onSuccess delayed called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStreamPromise() {
        var count = 0
        let promise = StreamPromise<Bool>()
        let expectation = expectationWithDescription("onSuccess fulfilled for future stream")
        promise.future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++count
            if count == 1 {
                expectation.fulfill()
            } else if count > 1 {
                XCTAssert(false, "onSuccess called more than 2 times")
            }
        }
        promise.future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }

    }
    
    func testWriteSuccessAndFailure() {
        var countSuccess = 0
        var countFailure = 0
        let stream = FutureStream<Bool>()
        let expectationFailure = expectationWithDescription("onFailure fulfilled for future stream")
        let expectationSuccess = expectationWithDescription("onSuccess fulfilled for future stream")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            ++countSuccess
            if countSuccess == 1 {
                expectationSuccess.fulfill()
            } else if countSuccess > 1 {
                XCTAssert(false, "onSuccess called more than 1 times")
            }
        }
        stream.onFailure {error in
            ++countFailure
            if countFailure == 1 {
                expectationFailure.fulfill()
            } else if countFailure > 1 {
                XCTAssert(false, "onFailure called more than 1 times")
            }
        }
        writeSuccesfulFutures(stream, true, 1)
        writeFailedFutures(stream, 1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}

