//
//  FutureForcompTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/29/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import SimpleFutures

class FutureForcompTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTwoFuturesSuccess() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let forcompExpectation = expectationWithDescription("forcomp fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2) {(value1, value2) in
            XCTAssert(value1, "forcomp apply value1 invalid")
            XCTAssert(value2 == 1, "forcomp apply value2 invalid")
            forcompExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTwoFuturesFailure() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onFailureFuture1Expectation = expectationWithDescription("future1 onFailue fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        future1.onSuccess {value in
            XCTAssert(false, "future1 onSuccess called")
        }
        future1.onFailure {error in
            onFailureFuture1Expectation.fulfill()
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2) {(value1, value2) in
            XCTAssert(false, "forconmp apply called")
        }
        promise1.failure(TestFailure.error)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testThreeFuturesSuccess() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let promise3 = Promise<Float>()
        let future3 = promise3.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onSuccessFuture3Expectation = expectationWithDescription("future3 onSuccess fulfilled")
        let forcompExpectation = expectationWithDescription("forcomp fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        future3.onSuccess {value in
            XCTAssert(value == 1, "future3 onSuccess value invalid")
            onSuccessFuture3Expectation.fulfill()
        }
        future3.onFailure {error in
            XCTAssert(false, "future3 onFailure called")
        }
        forcomp(future1, future2, future3) {(value1, value2, value3) in
            XCTAssert(value1, "forcomp apply value1 invalid")
            XCTAssert(value2 == 1, "forcomp apply value2 invalid")
            XCTAssert(value3 == 1.0, "forcomp apply value3 invalid")
            forcompExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        promise3.success(1.0)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testThreeFuturesFailure() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let promise3 = Promise<Float>()
        let future3 = promise3.future
        let onFailureFuture1Expectation = expectationWithDescription("future1 onFailure fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onSuccessFuture3Expectation = expectationWithDescription("future3 onSuccess fulfilled")
        future1.onSuccess {value in
            XCTAssert(false, "future1 onSuccess called")
        }
        future1.onFailure {error in
            onFailureFuture1Expectation.fulfill()
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        future3.onSuccess {value in
            XCTAssert(value == 1, "future3 onSuccess value invalid")
            onSuccessFuture3Expectation.fulfill()
        }
        future3.onFailure {error in
            XCTAssert(false, "future3 onFailure called")
        }
        forcomp(future1, future2, future3) {(value1, value2, value3) in
            XCTAssert(false, "forcomp apply called")
        }
        promise1.failure(TestFailure.error)
        promise2.success(1)
        promise3.success(1.0)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTwoFuturesSuccessFiltered() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let forcompExpectation = expectationWithDescription("forcomp fulfilled")
        let filterExpectation = expectationWithDescription("filter fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, filter:{(value1, value2) -> Bool in
                XCTAssert(value1, "forcomp filter value1 invalid")
                XCTAssert(value2 == 1, "forcomp filterbvalue2 invalid")
                filterExpectation.fulfill()
                return true
            }) {(value1, value2) in
                XCTAssert(value1, "forcomp apply value1 invalid")
                XCTAssert(value2 == 1, "forcomp apply value2 invalid")
                forcompExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testTwoFuturesFailureFiltered() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onFailureFuture1Expectation = expectationWithDescription("future1 onFailure fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        future1.onSuccess {value in
            XCTAssert(false, "future1 onSuccess called")
        }
        future1.onFailure {error in
            onFailureFuture1Expectation.fulfill()
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, filter:{(value1, value2) -> Bool in
            XCTAssert(false, "forcomp filter called")
            return false
            }) {(value1, value2) in
                XCTAssert(false, "forcomp called")
        }
        promise1.failure(TestFailure.error)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTwoFuturesFilterFailure() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let filterExpectation = expectationWithDescription("filter fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, filter:{(value1, value2) -> Bool in
                filterExpectation.fulfill()
                return false
            }) {(value1, value2) in
                XCTAssert(false, "forcomp called")
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testThreeFuturesSuccessFiltered() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let promise3 = Promise<Float>()
        let future3 = promise3.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onSuccessFuture3Expectation = expectationWithDescription("future3 onSuccess fulfilled")
        let forcompExpectation = expectationWithDescription("forcomp fulfilled")
        let filterExpectation = expectationWithDescription("filter fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        future3.onSuccess {value in
            XCTAssert(value == 1, "future3 onSuccess value invalid")
            onSuccessFuture3Expectation.fulfill()
        }
        future3.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, future3, filter:{(value1, value2, value3) -> Bool in
                XCTAssert(value1, "forcomp filter value1 invalid")
                XCTAssert(value2 == 1, "forcomp filter value2 invalid")
                XCTAssert(value3 == 1.0, "forcomp filter value3 invalid")
                filterExpectation.fulfill()
                return true
            }) {(value1, value2, value3) in
                XCTAssert(value1, "forcomp apply value1 invalid")
                XCTAssert(value2 == 1, "forcomp apply value2 invalid")
                XCTAssert(value3 == 1.0, "forcomp apply value3 invalid")
                forcompExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        promise3.success(1.0)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testThreeFuturesFailureFiltered() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let promise3 = Promise<Float>()
        let future3 = promise3.future
        let onFailureFuture1Expectation = expectationWithDescription("future1 onFailure fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onSuccessFuture3Expectation = expectationWithDescription("future3 onSuccess fulfilled")
        future1.onSuccess {value in
            XCTAssert(false, "future1 onSuccess called")
        }
        future1.onFailure {error in
            onFailureFuture1Expectation.fulfill()
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        future3.onSuccess {value in
            XCTAssert(value == 1, "future3 onSuccess value invalid")
            onSuccessFuture3Expectation.fulfill()
        }
        future3.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, future3, filter:{(value1, value2, value3) -> Bool in
                XCTAssert(false, "forcomp filter called")
                return false
            }) {(value1, value2, value3) in
                XCTAssert(false, "forcomp apply called")
        }
        promise1.failure(TestFailure.error)
        promise2.success(1)
        promise3.success(1.0)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testThreeFuturesFilterFailure() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let promise3 = Promise<Float>()
        let future3 = promise3.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onSuccessFuture3Expectation = expectationWithDescription("future3 onSuccess fulfilled")
        let filterExpectation = expectationWithDescription("filter fulfilled")
        future1.onSuccess {value in
            XCTAssert(value, "future1 onSuccess value invalid")
            onSuccessFuture1Expectation.fulfill()
        }
        future1.onFailure {error in
            XCTAssert(false, "future1 onFailure called")
        }
        future2.onSuccess {value in
            XCTAssert(value == 1, "future2 onSuccess value invalid")
            onSuccessFuture2Expectation.fulfill()
        }
        future2.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        future3.onSuccess {value in
            XCTAssert(value == 1, "future3 onSuccess value invalid")
            onSuccessFuture3Expectation.fulfill()
        }
        future3.onFailure {error in
            XCTAssert(false, "future2 onFailure called")
        }
        forcomp(future1, future2, future3, filter:{(value1, value2, value3) -> Bool in
                filterExpectation.fulfill()
                return false
            }) {(value1, value2, value3) in
                XCTAssert(false, "forcomp apply called")
        }
        promise1.success(true)
        promise2.success(1)
        promise3.success(1.0)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
