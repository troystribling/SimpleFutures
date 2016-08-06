//
//  StreamOnFailureTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamOnFailureTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnFailure_WhenCompletedBeforeCallbacksDefined_CompletesWithError() {
        let stream = FutureStream<Bool>()
        var onFailureCalled = 0
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        stream.onSuccess(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.onFailure(context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
            onFailureCalled += 1
        }
        XCTAssertEqual(onFailureCalled, 3)
    }
    
    func testOnSuccess_WhenCompletedBeforeCallbacksDefined_CompletesWithError() {
        let stream = FutureStream<Bool>()
        var onFailureCalled = 0
        stream.onSuccess(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.onFailure(context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
            onFailureCalled += 1
        }
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        XCTAssertEqual(onFailureCalled, 3)
    }
    
    func testOnSuccess_WhenCompletedBeforeAndAfterCallbacksDefined_CompletesWithError() {
        let stream = FutureStream<Bool>()
        var onFailureCalled = 0
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        stream.onSuccess(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.onFailure(context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
            onFailureCalled += 1
        }
        stream.failure(TestFailure.error)
        XCTAssertEqual(onFailureCalled, 3)
    }
    
}