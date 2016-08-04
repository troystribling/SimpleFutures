//
//  FutureRecoverWithTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureRecoverWithTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRecoverWith_WhenFutureSucceeds_CompletesSuccessfully() {
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
    
    func testRecoverWith_WhenFutureFailsAndRecoverySucceeds_CompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) {error -> Future<Bool> in
            return Future<Bool>(value: true)
        }
        future.failure(TestFailure.error)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }
    
    func testRecoverWith_WhenFutureFailsAndRecoveryFails_CompletesWithError() {
        let future = Future<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) {error -> Future<Bool> in
            throw TestFailure.recoveryError
        }
        future.failure(TestFailure.error)
        XCTAssertFutureFails(recovered, context: TestContext.immediate) { error in
            XCTAssertEqual(error._code, TestFailure.recoveryError._code)
        }
    }
 
    func testRecoverWith_WhenFutureSucceedsAndRecoveryReturnsSuccessfulFutureStream_CompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) {error -> FutureStream<Bool> in
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
    
    func testRecoverWith_WhenFutureFailsAndRecoveryReturnsSuccessfulFutureStream_CompletesSuccessfully() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) {error -> FutureStream<Bool> in
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
    
    func testRecoverWith_WhenFutureFailsAndRecoveryReturnsFailedFutureStream_CompletesWithError() {
        let future = Future<Bool>()
        let stream = FutureStream<Bool>()
        let recovered = future.recoverWith(context: TestContext.immediate) {error -> FutureStream<Bool> in
            return stream
        }
        future.failure(TestFailure.error)
        stream.failure(TestFailure.recoveryError)
        XCTAssertFutureStreamFails(recovered, context: TestContext.immediate, validations: [
            { error in
                XCTAssertEqual(error._code, TestFailure.recoveryError._code)
            }
        ])
    }

}
