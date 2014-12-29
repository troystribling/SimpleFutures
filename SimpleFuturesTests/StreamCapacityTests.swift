//
//  StreamCapacityTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamCapacityTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNoCapacity() {
        let promise = StreamPromise<Bool>()
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(10, message:"onSuccess future")
        future.onSuccess {value in
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, true, 10)
        XCTAssertEqual(future.count, 10, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testCacapcity() {
        let promise = StreamPromise<Bool>(capacity:2)
        let future = promise.future
        let onSuccessExpectation = fulfillAfterCalled(10, message:"onSuccess future")
        future.onSuccess {value in
            onSuccessExpectation()
        }
        writeSuccesfulFutures(promise, true, 10)
        XCTAssertEqual(future.count, 2, "future count invalid")
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
