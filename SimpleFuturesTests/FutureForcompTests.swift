//
//  FutureForcompTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/29/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
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
            XCTAssert(value1, "forcomp value1 invalid")
            XCTAssert(value2 == 1, "forcomp value2 invalid")
            forcompExpectation.fulfill()
        }
        promise1.success(true)
        promise2.success(1)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTwoFuturesFailure() {
        
    }

    func testThreeFuturesSuccess() {
        
    }

    func testThreeFuturesFailure() {
        
    }

    func testTwoFuturesSuccessFiltered() {
        
    }
    
    func testTwoFuturesFailureFiltered() {
        
    }

    func testTwoFuturesFilterFailure() {
        
    }

    func testThreeFuturesSuccessFiltered() {
        
    }
    
    func testThreeFuturesFailureFiltered() {
        
    }
    
    func testThreeFuturesFilterFailure() {
        
    }

}
