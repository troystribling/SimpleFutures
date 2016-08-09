//
//  FutureTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 8/7/16.
//  Copyright © 2016 Troy Stribling. All rights reserved.
//

import XCTest
@testable import SimpleFutures

class FutureTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }


    // MARK: - onSuccess -

    func testOnSuccess_WhenCompletedBeforeCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled = false
        future.success(true)
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        XCTAssertTrue(onSuccessCalled)
    }

    func testOnSuccess_WhenCompletedAfterCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled = false
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        XCTAssertTrue(onSuccessCalled)
    }

    func testOnSuccess_WhenCompletedWithMultipleCallbacksDefined_CompletesSuccessfully() {
        let future = Future<Bool>()
        var onSuccessCalled1 = false
        var onSuccessCalled2 = false
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled1 = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled2 = true
            XCTAssertTrue(value)
        }
        future.onFailure(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.success(true)
        XCTAssertTrue(onSuccessCalled1)
        XCTAssertTrue(onSuccessCalled2)
    }

    // MARK: - onFailure -

    func testOnFailure_CompletedBeforeCallbacksDefined_CompletesWithError() {
        let future = Future<Bool>()
        future.failure(TestFailure.error)
        XCTAssertFutureFails(future, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    func testOnFailure_CompletedAfterCallbacksDefined_CompletesWithError() {
        let future = Future<Bool>()
        var onFailureCalled = false
        future.onSuccess(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.failure(TestFailure.error)
        XCTAssertTrue(onFailureCalled)
    }

    func testOnFailure_WithMultipleCallbacksDefined_CompletesWithError() {
        let future = Future<Bool>()
        var onFailure1Called = false
        var onFailure2Called = false
        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailure1Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailure2Called = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }
        future.failure(TestFailure.error)
        XCTAssertTrue(onFailure1Called)
        XCTAssertTrue(onFailure2Called)
    }

    // MARK: - completeWith -

    func testCompletesWith_WhenDependentFutureCompletedFirst_CompletesSuccessfully() {
        let future = Future<Bool>()
        let futureCompleted = Future<Bool>()

        var onSuccessCalled = false
        var completedOnSuccessCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssert(value)
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value)
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.success(true)
        future.completeWith(context: TestContext.immediate, future: futureCompleted)

        XCTAssert(onSuccessCalled)
        XCTAssert(completedOnSuccessCalled)
    }

    func testCompletesWith_WhenDependentFutureCompletedLast_CompletesSuccessfully() {
        let future = Future<Bool>()
        let futureCompleted = Future<Bool>()

        var onSuccessCalled = false
        var completedOnSuccessCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            onSuccessCalled = true
            XCTAssert(value)
        }
        future.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        futureCompleted.onSuccess(context: TestContext.immediate) { value in
            completedOnSuccessCalled = true
            XCTAssert(value)
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            XCTFail()
        }

        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.success(true)

        XCTAssert(onSuccessCalled)
        XCTAssert(completedOnSuccessCalled)
    }

    func testCompletesWith_WhenDependentFutureFails_CompletesWithDependantFutureError() {
        let future = Future<Bool>()
        let futureCompleted =  Future<Bool>()

        var onFailureCalled = false
        var completedOnFailureCalled = false

        future.onSuccess(context: TestContext.immediate) { value in
            XCTFail()
        }
        future.onFailure(context: TestContext.immediate) { error in
            onFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)

        }
        futureCompleted.onSuccess(context: TestContext.immediate) {  value in
            XCTFail()
        }
        futureCompleted.onFailure(context: TestContext.immediate) { error in
            completedOnFailureCalled = true
            XCTAssertEqualErrors(error, TestFailure.error)
        }

        future.completeWith(context: TestContext.immediate, future: futureCompleted)
        futureCompleted.failure(TestFailure.error)
        
        XCTAssert(onFailureCalled)
        XCTAssert(completedOnFailureCalled)
        
    }

    // MARK: - map -

    func testMap_WhenFutureAndMapSucceed_MapCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { value -> Int in
            return 1
        }
        future.success(true)
        XCTAssertFutureSucceeds(mapped, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 1)
        }
    }

    func testMap_WhenFutureSucceedsAndMapFails_MapCalledCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { _ -> Int in
            throw TestFailure.error
        }
        future.success(true)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    func testMap_WhenFutureFails_MapNotCalledCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.map(context: TestContext.immediate) { value -> Int in
            XCTFail()
            return 1
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    // MARK: - flatMap -

    func testFlatMap_WhenFutureAndFlatMapSucceed_FlatMapCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) {value -> Future<Int> in
            return Future<Int>(value: 1)
        }
        future.success(true)
        XCTAssertFutureSucceeds(mapped, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 1)
        }
    }

    func testFlatMap_WhenFutureSucceedsAndFlatMapFails_FlatMapCalledCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> Future<Int> in
            throw TestFailure.error
        }
        future.success(true)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    func testFlatMap_WhenFutureFailsAndFlatMapReturnsFuture_FlatMapNotCalledCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> Future<Int> in
            XCTFail()
            return Future<Int>(value: 1)
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    func testFlatMap_WhenFutureSucceedsAndFlatMapFutureFails_FlatMapCalledCompletesWithError() {
        let future = Future<Bool>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> Future<Int> in
            return Future<Int>(error: TestFailure.error)
        }
        future.success(true)
        XCTAssertFutureFails(mapped, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    func testFlatMap_WhenFutureSucceedsAndFlatMapReturnsSuccessfulFutureStream_FlatCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Int>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> FutureStream<Int> in
            return stream
        }
        future.success(true)
        stream.success(1)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertEqual(value, 1)
            }
        ])
    }

    func testFlatMap_WhenFutureFailsAndFlatMapReturnsFutureStream_FlatMapNotCalledCompletesWithError() {
        let future = Future<Bool>()
        let stream = FutureStream<Int>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> FutureStream<Int> in
            XCTFail()
            return stream
        }
        future.failure(TestFailure.error)
        stream.success(1)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)
            }
        ])
    }

    func testFlatMap_WhenFutureSucceedsAndFlatMapFutureStreamStream_FlatMapCalledCompletesWithError() {
        let future = Future<Bool>()
        let stream = FutureStream<Int>()
        let mapped = future.flatMap(context: TestContext.immediate) { value -> FutureStream<Int> in
            return stream
        }
        future.success(true)
        stream.failure(TestFailure.error)
        XCTAssertFutureStreamFails(mapped, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.error)

            }
        ])
    }

    // MARK: - recover -

    func testRecover_WhenFutureSucceeds_RecoverNotCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recover(context: TestContext.immediate) { error -> Bool in
            XCTFail()
            return false
        }
        future.success(true)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }

    func testRecover_WhenFutureFailsAndRecoverySucceeds_RecoverCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recover(context: TestContext.immediate) { _ -> Bool in
            return true
        }
        future.failure(TestFailure.error)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }

    func testRecover_WhenFutureFailsAndRecoveryFails_RecoverCalledCompletesWithFailure() {
        let future = Future<Bool>()
        let recovered = future.recover(context: TestContext.immediate) { _ -> Bool in
            throw TestFailure.recoveryError
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(recovered, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.recoveryError)
        }
    }

    // MARK: - recoverWith -

    func testRecoverWith_WhenFutureSucceeds_RecoverWithNotCompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { _ -> Future<Bool> in
            XCTFail()
            return Future<Bool>()
        }
        future.success(true)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }

    func testRecoverWith_WhenFutureFailsAndRecoverySucceeds_RecoverWithCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { error -> Future<Bool> in
            return Future<Bool>(value: true)
        }
        future.failure(TestFailure.error)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }

    func testRecoverWith_WhenFutureFailsAndRecoveryFails_RecoverWithCalledCompletesWithError() {
        let future = Future<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { error -> Future<Bool> in
            throw TestFailure.recoveryError
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(recovered, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.recoveryError)
        }
    }

    func testRecoverWith_WhenFutureSucceedsAndRecoveryReturnsSuccessfulFutureStream_RecoverWithNotCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { error -> FutureStream<Bool> in
            XCTFail()
            return stream
        }
        future.success(true)
        stream.success(false)
        XCTAssertFutureStreamSucceeds(recovered, context: TestContext.immediate, validations: [
            { value in
                XCTAssert(value)
            }
        ])
    }

    func testRecoverWith_WhenFutureFailsAndRecoveryReturnsSuccessfulFutureStream_RecoverWithCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { error -> FutureStream<Bool> in
            return stream
        }
        future.failure(TestFailure.error)
        stream.success(false)
        XCTAssertFutureStreamSucceeds(recovered, context: TestContext.immediate, validations: [
            { value in
                XCTAssertFalse(value)
            }
        ])
    }

    func testRecoverWith_WhenFutureFailsAndRecoveryReturnsFailedFutureStream_RecoverWithCalledCompletesWithError() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) { error -> FutureStream<Bool> in
            return stream
        }
        future.failure(TestFailure.error)
        stream.failure(TestFailure.recoveryError)
        XCTAssertFutureStreamFails(recovered, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqualErrors(error, TestFailure.recoveryError)
            }
        ])
    }

    // MARK: - withFilter -

    func testWithFilter_WhenFutureAndFilterSucceed_FilterCalledCompletesSuccessfully() {
        let future = Future<Bool>()
        let filter = future.withFilter(context: TestContext.immediate) { value in
            return value
        }
        future.success(true)
        XCTAssertFutureSucceeds(filter, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }

    func testWithFilter_WhenFutureSuccedsAndFilterFails_FilterCalledCompletesWithError() {
        let future = Future<Bool>()
        let filter = future.withFilter(context: TestContext.immediate) { value in
            return value
        }
        future.success(false)
        XCTAssertFutureFails(filter, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, SimpleFuturesErrors.NoSuchElement)
        }
    }

    func testWithFilter_WhenFutureFails_FilterNotCalledCompletesWithError() {
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

    // MARK: - forEach -

    func testForEach_WhenFutureSucceeds_ForEachCalled() {
        let future = Future<Bool>()
        var forEachCalled = false
        future.forEach(context: TestContext.immediate) { value in
            forEachCalled = true
            XCTAssertTrue(value)
        }
        future.success(true)
        XCTAssertTrue(forEachCalled)
    }

    func testForEach_WhenFutureFails_ForEachNotCalled() {
        let future = Future<Bool>()
        future.forEach(context: TestContext.immediate) { _ in
            XCTFail()
        }
        future.failure(TestFailure.error)
    }

    // MARK: - andThen -

    func testAndThen_WhenFutureSucceeds_AndThenCalledCompletesdSuccessfully() {
        let future = Future<Bool>()
        var andThenCalled = false
        let andThen = future.andThen(context: TestContext.immediate) { _ in
            andThenCalled = true
        }
        future.success(true)
        XCTAssertFutureSucceeds(andThen, context: TestContext.immediate) { value in
            XCTAssert(value, "andThen onSuccess value invalid")
            XCTAssertTrue(andThenCalled)
        }
    }

    func testAndThen_WhenFutureFails_AndThenNotCalledCompletesWithError() {
        let future = Future<Bool>()
        let andThen = future.andThen(context: TestContext.immediate) { _ in
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(andThen, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

    // MARK: - cancel -

    func testOnSuccess_WhenCancled_DoesNotComplete() {
        let future = Future<Int>()
        let cancelToken = CancelToken()
        future.onSuccess(context: TestContext.immediate, cancelToken: cancelToken) { _ in
            XCTFail()
        }
        let status = future.cancel(cancelToken)
        future.success(1)
        XCTAssertTrue(status)
    }

    func testOnSuccess_WhenFutureCompleted_CancelFails() {
        let future = Future<Int>()
        let cancelToken = CancelToken()
        future.success(1)
        let status = future.cancel(cancelToken)
        XCTAssertFutureSucceeds(future, context: TestContext.immediate)
        XCTAssertFalse(status)
    }

    func testOnSuccess_WithInvalidCancelToken_CancelFails() {
        let future = Future<Int>()
        let cancelToken = CancelToken()
        var onSuccessCalled = false
        future.onSuccess(context: TestContext.immediate) { _ in
            onSuccessCalled = true
        }
        let status = future.cancel(cancelToken)
        future.success(1)
        XCTAssertFalse(status)
        XCTAssertTrue(onSuccessCalled)
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

    // MARK: - future -

    func testFuture_WhenClosureSucceeds_CompletesSuccessfully() {
        let result = future(context: TestContext.immediate) {
            return 1
        }
        XCTAssertFutureSucceeds(result, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 1)
        }
    }

    func testFuture_WhenClosureFails_CompletesWithError() {
        let result = future(context: TestContext.immediate) { Void -> Int in
            throw TestFailure.error
        }
        XCTAssertFutureFails(result, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(TestFailure.error, error)
        }
    }

    func testFuture_WithAutoclosure_CompletesSuccessfully() {
        let result = future(1 < 2)
        XCTAssertFutureSucceeds(result, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }


    // MARK: - fold -
    func testFold_WhenFuturesSucceed_CompletesSuccessfully() {
        let futures = [future(Int(1)), future(Int(2)), future(Int(3))]
        let result = futures.fold(context: TestContext.immediate, initial: 0) { $0 + $1 }
        XCTAssertFutureSucceeds(result, context: TestContext.immediate) { value in
            XCTAssertEqual(value, 6)
        }
    }

    func testFold_WhenFutureFails_CompletesWithError() {
        let futures = [future(Int(1)),
                       future(context: TestContext.immediate) { Void -> Int in throw TestFailure.error },
                       future(Int(2))]
        let result = futures.fold(context: TestContext.immediate, initial: 0) { $0 + $1 }
        XCTAssertFutureFails(result, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }


    // MARK: - sequence -
    func testSequence_WhenFuturesSucceed_CompletesSuccessfully() {
        let futures = [future(Int(1)), future(Int(2)), future(Int(3))]
        let result = futures.sequence(context: TestContext.immediate)
        XCTAssertFutureSucceeds(result, context: TestContext.immediate) { value in
            XCTAssertEqual(value, [1, 2, 3])
        }
    }

    func testSequence_WhenFutureFails_CompletesWithError() {
        let futures = [future(Int(1)),
                       future(context: TestContext.immediate) { Void -> Int in throw TestFailure.error },
                       future(Int(2))]
        let result = futures.sequence(context: TestContext.immediate)
        XCTAssertFutureFails(result, context: TestContext.immediate) { error in
            XCTAssertEqualErrors(error, TestFailure.error)
        }
    }

}
