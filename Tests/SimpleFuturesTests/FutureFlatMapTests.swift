//
//  FutureFlatMapTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureFlatMapTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFlatMap_WhenFutureAndFlatMapSucceed_FlatMapFutureCompletesSuccessfully() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) {value -> Future<Int> in
            return Future<Int>(result: 1)
        }
        future.success(true)
        XCTAssertFutureSucceeds(mapped, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
        }
    }
    
    func testFlatMap_WhenFutureSucceedsAndFlatMapFails_FlatMapFutureCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> Future<Int> in
            throw TestFailure.error
        }
        future.success(true)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqual(error._code, TestFailure.error._code)
        }
    }

    func testFlatMap_WhenFutureFailsAndFlatMapSucceeds_FlatMapFutureCompletesSuccessfully() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> Future<Int> in
            return Future<Int>(result: 1)
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqual(error._code, TestFailure.error._code)
        }
    }
    
    func testFlatMap_WhenFutureSucceedsAndFlatMapReturnsSuccessfulFutureStream_FlatMapFutureCompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Int>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> FutureStream<Int> in
            return stream
        }
        future.success(true)
        stream.success(1)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            }
        ])
    }
    
    func testFlatMap_WhenFutureSucceedsAndFlatMapReturnsFailedFutureStream_FlatMapFutureCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> FutureStream<Int> in
            throw TestFailure.error
        }
        future.success(true)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqual(error._code, TestFailure.error._code)
            }
        ])
    }
    
    func testFlatMap_WhenFutureFailsAndFlatMapReturnsSuccessfulFutureStream_FlatMapFutureCompletesWithError() {
        let future = Future<Bool>()
        let stream = FutureStream<Int>()
        let mapped = future.flatMap(context: TestContext.immediate) {value -> FutureStream<Int> in
            return stream
        }
        future.failure(TestFailure.error)
        stream.success(1)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqual(error._code, TestFailure.error._code)
            }
        ])
    }
    
}
