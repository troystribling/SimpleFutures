//
//  FutureStreamCompleteWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/25/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamCompleteWithTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

//    func testImmediate() {
//        var count = 0
//        let promise = StreamPromise<Bool>()
//        let stream = promise.future
//        let expectation = expectationWithDescription("onSuccess fulfilled for future stream")
//        writeSuccesfulFutures(promise, true, 2)
//        stream.onSuccess {value in
//            XCTAssertTrue(value, "Invalid value")
//            ++count
//            if count == 2 {
//                expectation.fulfill()
//            } else if count > 2 {
//                XCTAssert(false, "onSuccess called more than 2 times")
//            }
//        }
//        stream.onFailure {error in
//            XCTAssert(false, "onFailure called")
//        }
//        waitForExpectationsWithTimeout(2) {error in
//            XCTAssertNil(error, "\(error)")
//        }
//    }
    

}
