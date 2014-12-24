//
//  FutureStreamWithFilter.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/23/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class FutureStreamWithFilter: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulFilter() {
        var count = 0
        var countFilter = 0
        var countFilterSuccess = 0
        let stream = FutureStream<Bool>()
        let expectationFilter = expectationWithDescription("fullfilled for withFilter")
        let expectationFilterFuture = expectationWithDescription("onSuccess fullfilled for filtered future")
        let expectation = expectationWithDescription("onSuccess fullfilled")
        stream.onSuccess {value in
            XCTAssert(value, "future onSucces value invalid")
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
        let filter = stream.withFilter {value in
            ++countFilter
            if countFilter == 2 {
                expectationFilter.fulfill()
            } else if countFilter > 2 {
                XCTAssert(false, "withFilter called more than 2 times")
            }
            return value
        }
        stream.onSuccess {value in
            XCTAssert(value, "filter future onSuccess value invalid")
            ++countFilterSuccess
            if countFilterSuccess == 2 {
                expectationFilterFuture.fulfill()
            } else if countFilterSuccess > 2 {
                XCTAssert(false, "withFilter onSuccess called more than 2 times")
            }
        }
        stream.onFailure {error in
            XCTAssert(false, "filter future onFailure called")
        }
        writeSuccesfulFutures(stream, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedFilter() {
    }
    
    func testFailedFuture() {
    }

}
