//
//  FutureMapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureMapTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMap_WhenFutureAndMapSucceed_MapFutureCompletesSuccessfully() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { value -> Int in
            return 1
        }
        future.success(true)
        XCTAssertFutureSucceeds(mapped, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 1)
        }
    }
    
    func testMap_WhenFutureSucceedsAndMapFails_MapFutureCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { _ -> Try<Int> in
            throw TestFailure.error
        }
        future.success(true)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqual(error._code, TestFailure.error._code)
        }
    }
    
    func testMap_WhenFutureFailsAndMapSucceeds_MapFutureCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { value -> Int in
            return 1
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqual(error._code, TestFailure.error._code)
        }
    }
    
}
