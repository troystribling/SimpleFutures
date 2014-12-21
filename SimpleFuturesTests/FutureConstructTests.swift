//
//  FutureConstructTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureContructTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSucces() {
        let expectation = expectationWithDescription("Imediate future failure")
        let test = future {
            Try(true)
        }
        test.onSuccess {value in
            XCTAssert(value, "onSuccess value invalid")
            expectation.fulfill()
        }
        test.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailure() {
        let expectation = expectationWithDescription("Imediate future failure")
        let test = future {
            Try<Bool>(TestFailure.error)
        }
        test.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        test.onFailure {error in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}

