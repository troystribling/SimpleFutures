//
//  FutureWithFilterTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/23/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureWithFilterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWithFilter_WhenFutureAndFilterSucceed_FilterFutureCompletesSuccessfully() {
        let future = Future<Bool>()
        let filter = future.withFilter(context: TestContext.immediate) { value in
            return value
        }
        future.success(true)
        XCTAssertFutureSucceeds(filter, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }
    
    func testWithFilter_WhenFutureSuccedsAndFilterFails_FilterFutureCompletesWithError() {
        let future = Future<Bool>()
        let filter = future.withFilter(context: TestContext.immediate) { value in
            return value
        }
        future.success(false)
        XCTAssertFutureFails(filter, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, SimpleFuturesErrors.filterFailed)
        }
    }
    
    func testWithFilter_WhenFutureFails_FilterFutureCompletesWithError() {
        let future = Future<Bool>()
        let filter = future.withFilter(context: TestContext.immediate) { value in
            XCTFail()
            return value
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(filter, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }
}
