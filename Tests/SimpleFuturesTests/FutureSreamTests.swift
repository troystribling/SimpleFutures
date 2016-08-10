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

    func testFlatMap_WhenFutureStreamAndFlatMapSucceed_FlatMapCalledCompletesSuccessfully() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> FutureStream<Bool> in
            let result = FutureStream<Bool>()
            result.success(value > 1)
            return result
        }
        stream.success(1)
        stream.success(2)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertFalse(value)
            },
            { value in
                XCTAssertTrue(value)
            }
        ])
    }

    func testFlatMap_WhenFutureStreamFails_FlatMapNotCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> FutureStream<Bool> in
            let result = FutureStream<Bool>()
            result.success(value > 1)
            return result
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

    func testFlatMap_WhenFutureStreamSucceedsAndFlatMapFails_FlatMapCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> FutureStream<Bool> in
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

    func testFlatMap_WhenFutureStreamSucceedsAndFlatMapToFailedFutureStream_FlatMapCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> FutureStream<Bool> in
            let result = FutureStream<Bool>()
            result.failure(TestFailure.error)
            return result
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

    func testFlatMap_WhenFutureStreamSuccedsAndFlatMapFutureStreamCompletesMultipleTimes_FlatMapCalledCompletesSuccessfully() {
        let stream = FutureStream<Int>()
        let result = FutureStream<Bool>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> FutureStream<Bool> in
            return result
        }
        stream.success(1)
        stream.success(2)
        result.success(true)
        result.success(false)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertTrue(value)
            },
            { value in
                XCTAssertTrue(value)
            },
            { value in
                XCTAssertFalse(value)
            },
            { value in
                XCTAssertFalse(value)
            }
       ])
    }

    func testFlatMap_WhenFutureStreamSuccedsAndFlatMapReturnsSuccessfulFuture_FlatMapCalledCompletesSuccessfully() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> Future<Bool> in
            return Future(value: value > 1)
        }
        stream.success(1)
        stream.success(2)
        XCTAssertFutureStreamSucceeds(mapped, context: TestContext.immediate, validations: [
            { value in
                XCTAssertFalse(value)
            },
            { value in
                XCTAssertTrue(value)
            }
        ])
    }

    func testFlatMap_WhenFutureStreamSuccedsAndFlatMapReturnsFailedFuture_FlatMapCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> Future<Bool> in
            return Future(error: TestFailure.error)
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

    func testFlatMap_WhenFutureStreamFailsAndFlatMapReturnsFuture_FlatMapNotCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> Future<Bool> in
            XCTFail()
            return Future(value: value > 1)
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

    func testFlatMap_WhenFlatMapFailsReturningFuture_FlatMapCalledCompletesWithError() {
        let stream = FutureStream<Int>()
        let mapped = stream.flatMap(context: TestContext.immediate) { value -> Future<Bool> in
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

    // MARK: - recover -

    

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

    func testCancel_ForOnSuccess_DoesNotComplete() {

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
