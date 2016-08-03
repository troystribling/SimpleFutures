//
//  FutureForEachTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/28/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureForEachTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testForEach_WhenFutureSucceeds_IsCalled() {
        let future = Future<Bool>()
        var forEachCalled = false
        future.forEach(context: TestContext.immediate) { value in
            forEachCalled = true
            XCTAssertTrue(value)
        }
        future.success(true)
        XCTAssertTrue(forEachCalled)
    }
    
    func testForEach_WhenFutureFails_IsNotCalled() {
        let future = Future<Bool>()
        future.forEach(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.failure(TestFailure.error)
    }
    
}
