//
//  FutureSreamTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 8/8/16.
//  Copyright © 2016 Troy Stribling. All rights reserved.
//

import XCTest
@testable import SimpleFutures

class FutureSreamTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - onSuccess -
    
    func testOnSuccess_WhenCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.success(true)
        future.success(true)
        future.success(true)
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(onSuccessCalled, 3)
    }

    func testOnSuccess_WhenCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled, 3)
    }

    func testOnSuccess_WhenCompletedBeforeAndAfterCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        future.success(true)
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled, 3)
    }

    func testOnSuccess_WhenCompletedWithMultipleCallbacksDefined_CompletesSuccessfully() {
        let future = FutureStream<Bool>()
        var onSuccessCalled1 = 0
        var onSuccessCalled2 = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled1 += 1
            }
        }
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled2 += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        future.success(true)
        future.success(true)
        XCTAssertEqual(onSuccessCalled1, 3)
        XCTAssertEqual(onSuccessCalled2, 3)
    }

    func testOnSuccess_WhenCompletedWithSuccessAndFailure_CompletesSuccessfullyAndWithError() {
        let future = FutureStream<Bool>()
        var onSuccessCalled = 0
        var onFailureCalled = 0
        future.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
            onFailureCalled += 1
        }
        future.success(true)
        future.success(true)
        future.success(true)
        future.failure(TestFailure.error)
        future.failure(TestFailure.error)
        future.failure(TestFailure.error)
        XCTAssertEqual(onSuccessCalled, 3)
        XCTAssertEqual(onFailureCalled, 3)
    }

    // MARK: - onFailure -

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

    // MARK: - capacity -

    func testOnSuccess_WithInfiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>()
        var onSuccessCalled = 0
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(stream.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithInfiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>()
        var onSuccessCalled = 0
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        XCTAssertEqual(stream.count, 10)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    func testOnSuccess_WithFiniteCapacityCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>(capacity: 2)
        var onSuccessCalled = 0
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertEqual(stream.count, 2)
        XCTAssertEqual(onSuccessCalled, 2)
    }

    func testOnSuccess_WithFiniteCapacityCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let stream = FutureStream<Bool>(capacity: 2)
        var onSuccessCalled = 0
        stream.onSuccess(context: TestContext.immediate) {value in
            if value {
                onSuccessCalled += 1
            }
        }
        stream.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        stream.success(true)
        XCTAssertEqual(stream.count, 2)
        XCTAssertEqual(onSuccessCalled, 10)
    }

    // MARK: - map -

    func testMap_WhenFutureStreamAndMapSucceed_MapCalledCompletesSuccessfully() {
        let stream = FutureStream<Int>()
        let mapped = stream.map(context: TestContext.immediate) { value -> Int in
            return value + 1
        }
        stream.success(1)
        stream.success(2)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertEqual(value, 2)
            },
            { value in
                XCTAssertEqual(value, 3)
            }
        ])
    }

    func testMap_WhenFutureStreamFails_MapNotCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.map(context: TestContext.immediate) {value -> Int in
            XCTFail()
            return 1
        }
        stream.failure(TestFailure.error)
        stream.failure(TestFailure.error)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            },
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            }
        ])
    }

    func testMap_WhenFutureStreamSuccedsAndMapFails_MapCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.map(context: TestContext.immediate) {value -> Int in
            throw TestFailure.error
        }
        stream.success(1)
        stream.success(2)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            },
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            }
        ])
    }

    // MARK: - flatMap -

    func testMap_WhenFutureStreamAndFlatMapSucceed_FlatMapCalledCompletesSuccessfully() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let flatmapExpectation = XCTExpectFullfilledCountTimes(2, message:"flatMap")
        let onSuccessMappedExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatMap {value -> Future<Int> in
            flatmapExpectation()
            let promise = Promise<Int>()
            promise.success(1)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            onSuccessMappedExpectation()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped future onFailure called")
        }
        writeSuccesfulFutures(promise, value:true, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testMap_WhenFutureStreamFails_FlatMapNotCalledCompletesWithError() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onFailureExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure future")
        let onFailureMappedExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        let mapped = stream.flatMap {value -> Future<Int> in
            XCTAssert(false, "flatMap called")
            let promise = Promise<Int>()
            promise.failure(TestFailure.error)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped future onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeFailedFutures(promise, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testMap_WhenFutureStreamSuccedsAndFlatMapFails_FlatMapCalledCompletesWithError() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let flatmapExpectation = XCTExpectFullfilledCountTimes(2, message:"flatMap")
        let onFailureMappedExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatMap {value -> Future<Int> in
            flatmapExpectation()
            let promise = Promise<Int>()
            promise.failure(TestFailure.error)
            return promise.future
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped future onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeSuccesfulFutures(promise, value:true, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testSuccessfulMappingToFutureStream() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let flatmapExpectation = XCTExpectFullfilledCountTimes(2, message:"flatMap")
        let onSuccessMappedExpectation = XCTExpectFullfilledCountTimes(4, message:"onSuccess mapped future")
        stream.onSuccess {value in
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatMap {value -> FutureStream<Int> in
            flatmapExpectation()
            let promise = StreamPromise<Int>()
            if value {
                writeSuccesfulFutures(promise, values:[1, 2])
            } else {
                writeSuccesfulFutures(promise, values:[3, 4])
            }
            return promise.stream
        }
        mapped.onSuccess {value in
            XCTAssert(value == 1 || value == 2 || value == 3 || value == 4, "mapped onSuccess value invalid")
            onSuccessMappedExpectation()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped future onFailure called")
        }
        writeSuccesfulFutures(promise, values:[true, false])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailedMappingToFutureStream() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onFailureExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure future")
        let onFailureMappedExpectation = XCTExpectFullfilledCountTimes(2, message:"onFailure mapped future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        let mapped = stream.flatMap {value -> FutureStream<Int> in
            XCTAssert(false, "flatMap called")
            return  StreamPromise<Int>().stream
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped future onSuccess called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeFailedFutures(promise, times:2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testSuccessfulMappingToFailedFutureStream() {
        let promise = StreamPromise<Bool>()
        let stream = promise.stream
        let onSuccessExpectation = XCTExpectFullfilledCountTimes(2, message:"onSuccess future")
        let flatmapExpectation = XCTExpectFullfilledCountTimes(2, message:"flatMap")
        let onFailureMappedExpectation = XCTExpectFullfilledCountTimes(4, message:"onFailure mapped future")
        stream.onSuccess {value in
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = stream.flatMap {value -> FutureStream<Int> in
            flatmapExpectation()
            let promise = StreamPromise<Int>()
            writeFailedFutures(promise, times:2)
            return promise.stream
        }
        mapped.onSuccess {value in
            XCTAssert(false, "mapped future onSucces called")
        }
        mapped.onFailure {error in
            onFailureMappedExpectation()
        }
        writeSuccesfulFutures(promise, values:[true, false])
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }


    // MARK: - andThen -

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

    // MARK: - cancel -

    func testOnSuccess_WhenCancled_DoesNotComplete() {

    }

    func testOnSuccess_WithInvalidCancelToken_CancelFails() {

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

    func testFlatMap_ReturningFutureWhenCancelled_DoesNotComplete() {

    }
    
    func testRecoverWith_ReturningFutureWhenCancelled_DoesNotComplete() {
        
    }

}
