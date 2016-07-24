//
//  FutureCancelTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 7/24/16.
//  Copyright © 2016 Troy Stribling. All rights reserved.
//

import XCTest
@testable import SimpleFutures

class FutureCancelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOnSuccess_WhenCancled_DoesNotComplete() {
        let promise = Promise<Int>()
        let future = promise.future
        let cancelToken = CancelToken()
        future.onSuccess(TestContext.immediate, cancelToken: cancelToken) { _ in
            XCTFail("onSuccess called")
        }
        let status = future.cancel(cancelToken)
        promise.success(1)
        XCTAssertTrue(status, "Cancel returned invalid status")
    }

    func testOnSuccess_WhenFutureCompleted_CancelFails() {
        let promise = Promise<Int>()
        let future = promise.future
        let cancelToken = CancelToken()
        promise.success(1)
        let status = future.cancel(cancelToken)
        XCTAssertFutureSucceeds(future, context: TestContext.immediate)
        XCTAssertFalse(status, "Cancel returned invalid status")
    }

    func testOnSuccess_WithInvalidCancelToken_CancelFails() {
        let promise = Promise<Int>()
        let future = promise.future
        let cancelToken = CancelToken()
        var onSuccessCalled = false
        future.onSuccess(TestContext.immediate) { _ in
            onSuccessCalled = true
        }
        let status = future.cancel(cancelToken)
        promise.success(1)
        XCTAssertFalse(status, "Cancel returned invalid status")
        XCTAssertTrue(onSuccessCalled, "onSuccess not called")
    }

    func testOnFailure_WhenCancled_DoesNotComplete() {

    }

    func testMap_WhenCancled_DoesNotComplete() {

    }

    func testFlatMap_WhenCancled_DoesNotComplete() {
        
    }

    func testAndThen_WhenCancled_DoesNotComplete() {

    }

    func testRecover_WhenCancled_DoesNotComplete() {

    }

    func testRecoverWith_WhenCancled_DoesNotComplete() {

    }

    func testWithFilter_WhenCancled_DoesNotComplete() {

    }

    func testForEach_WhenCancled_DoesNotComplete() {

    }

    func testFlatMap_ReturningFutureStreamWhenCancelled_DoesNotComplete() {

    }

    func testRecoverWith_ReturningFutureStreamWhenCancelled_DoesNotComplete() {
        
    }

}
