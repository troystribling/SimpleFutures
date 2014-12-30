//
//  FutureForcompYieldTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/29/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureForcompYieldTests: XCTestCase {

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
        let onSuccessForcompExpectation = expectationWithDescription("forcomp onSuccess fullfilled")
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
        let forcompFuture = forcomp(future1, future2) {(value1, value2) -> Try<Bool> in
            XCTAssert(value1, "forcomp value1 invalid")
            XCTAssert(value2 == 1, "forcomp value2 invalid")
            forcompExpectation.fulfill()
            return Try(true)
        }
        forcompFuture.onSuccess {value in
            XCTAssert(value, "forcompFuture ionSuccess value invalid")
            onSuccessForcompExpectation.fulfill()
        }
        forcompFuture.onFailure {error in
            XCTAssert(false, "forcompFuture onSuccess called")
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
        let onFailureFuture1Expectation = expectationWithDescription("future1 onFailure fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let onFailureForcompExpectation = expectationWithDescription("forcomp onFailure fullfilled")
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
        let forcompFuture = forcomp(future1, future2) {(value1, value2) -> Try<Bool> in
            XCTAssert(false, "forcomp called")
            return Try(true)
        }
        forcompFuture.onSuccess {value in
            XCTAssert(false, "forcomp onSuccess called")
        }
        forcompFuture.onFailure {error in
            onFailureForcompExpectation.fulfill()
        }
        promise1.failure(TestFailure.error)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTwoFuturesYieldFailure() {
        
    }

    func testThreeFuturesSuccess() {
        
    }
    
    func testThreeFuturesFailure() {
        
    }

    func testThreeFuturesYieldFailure() {
        
    }

    func testTwoFuturesSuccessFiltered() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let forcompExpectation = expectationWithDescription("forcomp fulfilled")
        let filterExpectaion = expectationWithDescription("filter fulfilled")
        let onSuccessForcompExpectation = expectationWithDescription("forcomp onSuccess fullfilled")
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
        let forcompFuture = forcomp(future1, future2, filter:{(value1, value2) -> Bool in
                XCTAssert(value1, "forcomp value1 invalid")
                XCTAssert(value2 == 1, "forcomp value2 invalid")
                filterExpectaion.fulfill()
                return true
            }) {(value1, value2) -> Try<Bool> in
                XCTAssert(value1, "forcomp value1 invalid")
                XCTAssert(value2 == 1, "forcomp value2 invalid")
                forcompExpectation.fulfill()
                return Try(true)
        }
        forcompFuture.onSuccess {value in
            XCTAssert(value, "forcompFuture onSuccess value invalid")
            onSuccessForcompExpectation.fulfill()
        }
        forcompFuture.onFailure {error in
            XCTAssert(false, "forcompFuture onSuccess called")
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testTwoFuturesFailureFiltered() {
    }
    
    func testTwoFuturesFilterFailure() {
        let promise1 = Promise<Bool>()
        let future1 = promise1.future
        let promise2 = Promise<Int>()
        let future2 = promise2.future
        let onSuccessFuture1Expectation = expectationWithDescription("future1 onSuccess fulfilled")
        let onSuccessFuture2Expectation = expectationWithDescription("future2 onSuccess fulfilled")
        let filterExpectaion = expectationWithDescription("filter fulfilled")
        let onFailureForcompFutureExpectation = expectationWithDescription("forcomp onSuccess fullfilled")
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
        let forcompFuture = forcomp(future1, future2, filter:{(value1, value2) -> Bool in
            XCTAssert(value1, "forcomp value1 invalid")
            XCTAssert(value2 == 1, "forcomp value2 invalid")
            filterExpectaion.fulfill()
            return false
            }) {(value1, value2) -> Try<Bool> in
                XCTAssert(false, "forcomp called")
                return Try(true)
        }
        forcompFuture.onSuccess {value in
            XCTAssert(false, "forcompFuture onSuccess called")
        }
        forcompFuture.onFailure {error in
            onFailureForcompFutureExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testThreeFuturesSuccessFiltered() {
        
    }
    
    func testThreeFuturesFailureFiltered() {
        
    }
    
    func testThreeFuturesFilterFailure() {
        
    }

}
