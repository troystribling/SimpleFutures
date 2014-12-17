//
//  FutureTests.swift
//  SimpleFuturesTests
//
//  Created by Troy Stribling on 12/14/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

struct TestFailure {
    static let error = NSError(domain:"SimpleFutures", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

class FuturesSuccessTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Imediate future success")
        future.success(true)
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testImmediateAndDelayed() {
        let future = Future<Bool>()
        let expectationImmediate = expectationWithDescription("Immediate future success")
        let expectationDelayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssertTrue(value, "Delayed Invalid value")
            expectationDelayed.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Delayed onFailure called")
        }
        future.success(true)
        future.onSuccess {value in
            XCTAssertTrue(value, "Immediate Invalid value")
            expectationImmediate.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Immediate onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromise() {
        let promise = Promise<Bool>()
        let expectation = expectationWithDescription("Success from promise")
        promise.future.onSuccess {value in
            XCTAssertTrue(value, "Invalid value")
            expectation.fulfill()
        }
        promise.future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

class FutureFailureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImediate() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Imediate future failure")
        future.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayed() {
        let future = Future<Bool>()
        let expectation = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayed() {
        let future = Future<Bool>()
        let expectationImmediate = expectationWithDescription("Immediate future success")
        let expectationDelayed = expectationWithDescription("Delayed future success")
        future.onSuccess {value in
            XCTAssert(false, "Delayed onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "Delayed onFailure \(error)")
            expectationDelayed.fulfill()
        }
        future.failure(TestFailure.error)
        future.onSuccess {value in
            XCTAssert(false, "Immediate onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, 100, "Immediate onFailure \(error)")
            expectationImmediate.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromise() {
        let promise = Promise<Bool>()
        let expectation = expectationWithDescription("Success from promise")
        promise.future.onSuccess {value in
            XCTAssert(false, "onSuccess called")
        }
        promise.future.onFailure {error in
            XCTAssertEqual(error.code, 100, "\(error)")
            expectation.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

class FutureCompleteTests : XCTestCase {
  
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImmediateSuccess() {
        let future = Future<Bool>()
        let expectationOnComlpete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationOnSuccess = expectationWithDescription("Immediate onSuccess fullfilled")
        future.complete(Try(true))
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Invalid value")
                expectationOnComlpete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "Failure value")
            }
        }
        future.onSuccess {value in
            XCTAssert(value, "onSuccess value invalid")
            expectationOnSuccess.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateFailure() {
        let future = Future<Bool>()
        let expectationOnComplete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationOnFailure = expectationWithDescription("Immediate onFailure fullfilled")
        future.failure(TestFailure.error)
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(false, "Success result")
            case .Failure(let error):
                expectationOnComplete.fulfill()
            }
        }
        future.onSuccess {result in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            expectationOnFailure.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayedSuccess() {
        let future = Future<Bool>()
        let expectationOnComlpete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationOnSuccess = expectationWithDescription("Immediate onSuccess fullfilled")
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Invalid value")
                expectationOnComlpete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "Failure value")
            }
        }
        future.onSuccess {value in
            XCTAssert(value, "onSuccess value invalid")
            expectationOnSuccess.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        future.complete(Try(true))
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDelayedFailure() {
        let future = Future<Bool>()
        let expectationOnComplete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationOnFailure = expectationWithDescription("Immediate onFailure fullfilled")
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(false, "Success result")
            case .Failure(let error):
                expectationOnComplete.fulfill()
            }
        }
        future.onSuccess {result in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            expectationOnFailure.fulfill()
        }
        future.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayedSuccess() {
        let future = Future<Bool>()
        let expectationImmediateOnComlpete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationImmediateOnSuccess = expectationWithDescription("Immediate onSuccess fullfilled")
        let expectationDelayedOnComlpete = expectationWithDescription("Delayed onComplete fullfilled")
        let expectationDelayedOnSuccess = expectationWithDescription("Delayed onSuccess fullfilled")
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Delayed Invalid value")
                expectationDelayedOnComlpete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "Delayed Failure value")
            }
        }
        future.onSuccess {value in
            XCTAssert(value, "Delayed onSuccess value invalid")
            expectationDelayedOnSuccess.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Delayed onFailure called")
        }
        future.complete(Try(true))
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Immediate Success invalid value")
                expectationImmediateOnComlpete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "Immediate Failure value")
            }
        }
        future.onSuccess {value in
            XCTAssert(value, "Immediate onSuccess value invalid")
            expectationImmediateOnSuccess.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "Immediate onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testImmediateAndDelayedFailure() {
        let future = Future<Bool>()
        let expectationImmediateOnComplete = expectationWithDescription("Immediate onComplete fullfilled")
        let expectationImmediateOnFailure = expectationWithDescription("Immediate onFailure fullfilled")
        let expectationDelayedOnComplete = expectationWithDescription("Delayed onComplete fullfilled")
        let expectationDelayedOnFailure = expectationWithDescription("Delayed onFailure fullfilled")
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(false, "Delayed success result")
            case .Failure(let error):
                expectationDelayedOnComplete.fulfill()
            }
        }
        future.onSuccess {result in
            XCTAssert(false, "Delayed Success called")
        }
        future.onFailure {error in
            expectationDelayedOnFailure.fulfill()
        }
        future.failure(TestFailure.error)
        future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(false, "Immediate success result")
            case .Failure(let error):
                expectationImmediateOnComplete.fulfill()
            }
        }
        future.onSuccess {result in
            XCTAssert(false, "Immediate Success called")
        }
        future.onFailure {error in
            expectationImmediateOnFailure.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromiseSuccess() {
        let promise = Promise<Bool>()
        let expectationOnComplete = expectationWithDescription("onComplete fulfilled")
        let expectationOnSuccess = expectationWithDescription("onSuccess fulfilled")
        promise.future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(resultWrapper.value, "Success invalid value")
                expectationOnComplete.fulfill()
            case .Failure(let error):
                XCTAssert(false, "onComplete Failure called")
            }
        }
        promise.future.onSuccess {value in
            XCTAssert(value, "onSuccess invalid value")
            expectationOnSuccess.fulfill()
        }
        promise.future.onFailure {error in
            XCTAssert(false, "onfailure called")
        }
        promise.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPromiseFailure() {
        let promise = Promise<Bool>()
        let expectationOnComplete = expectationWithDescription("onComplete fulfilled")
        let expectationOnFailure = expectationWithDescription("onFailure fulfilled")
        promise.future.onComplete {result in
            switch result {
            case .Success(let resultWrapper):
                XCTAssert(false, "onComplete Success called")
            case .Failure(let error):
                expectationOnComplete.fulfill()
            }
        }
        promise.future.onSuccess {value in
            XCTAssert(value, "onSuccess invalid value")
        }
        promise.future.onFailure {error in
            expectationOnFailure.fulfill()
        }
        promise.failure(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
    
class FutureMapTests : XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessfulMapping() {
        let future = Future<Bool>()
        let expectationMapped = expectationWithDescription("OnSuccess fulfilled for mapped future")
        let expectation = expectationWithDescription("OnSuccess fulfilled")
        future.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let mapped = future.map {value -> Try<Int> in
            return Try(Int(1))
        }
        mapped.onSuccess {value in
            XCTAssertEqual(value, 1, "mapped onSuccess value invalid")
            expectationMapped.fulfill()
        }
        mapped.onFailure {error in
            XCTAssert(false, "mapped onFailure called")
        }
        future.success(true)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailedMapping() {
        
    }

    func testMappingToFailedFuture() {
        
    }
}

