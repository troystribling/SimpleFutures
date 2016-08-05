//
//  StreamAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class StreamAndThenTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAndThen_WhenFutureStreamSucceeds_AndThenCalledCompletesSuccessfully() {
        let stream = FutureStream<Bool>()
        var andThenCalled = 0
        let andThen = stream.andThen(context: TestContext.immediate) { _ in
            andThenCalled += 1
        }
        stream.success(true)
        stream.success(true)
        XCTAssertFutureStreamSucceeds(andThen, context: TestContext.immediate, validations: [
            { value in
                XCTAssertTrue(value)
            },
            { value in
                XCTAssertTrue(value)
            }
        ])
        XCTAssertEqual(andThenCalled, 2)
    }

    func testAndThen_WhenFutureStreamFails_AndThenNotCalledCompletesWithFailure() {
        let stream = FutureStream<Bool>()
        let andThen = stream.andThen(context: TestContext.immediate) {result in
            XCTFail()
        }
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        XCTAssertFutureStreamFails(andThen, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            },
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            }
        ])
    }
    
}