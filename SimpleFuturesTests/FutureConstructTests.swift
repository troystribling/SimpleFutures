//
//  FutureConstructTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
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
        let onSuccessExpectation = expectationWithDescription("Imediate future failure")
        let test = future {
            Try(true)
        }
        test.onSuccess {value in
            XCTAssert(value, "onSuccess value invalid")
            onSuccessExpectation.fulfill()
        }
        test.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailure() {
        let onFailureExpectation = expectationWithDescription("Imediate future failure")
        let test = future {
            Try<Bool>(TestFailure.error)
        }
        test.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        test.onFailure {error in
            onFailureExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}

