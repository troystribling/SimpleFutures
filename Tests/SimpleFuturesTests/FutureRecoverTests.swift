//
//  FutureRecoverTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
@testable import SimpleFutures

class FutureRecoverTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRecover_WhenFutureSucceeds_CompletesSuccessfully() {
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
    
    func testRecover_WhenFutureFailsAndRecoverySucceeds_CompletesSuccessfully() {
        let future = Future<Bool>()
        let recovered = future.recover(context: TestContext.immediate) { _ -> Bool in
            return true
        }
        future.failure(TestFailure.error)
        XCTAssertFutureSucceeds(recovered, context: TestContext.immediate) { value in
            XCTAssertTrue(value)
        }
    }
    
//    func testRecover_WhenFutureFailsAndRecoveryFails_CompletesWithFailure() {
//        let future = Future<Bool>()
//        let recovered = future.recover(context: TestContext.immediate) { _ -> Bool in
//            return false
//        }
//        future.failure(TestFailure.error)
//        XCTAssertFutureFails(recovered, context: TestContext.immediate) { error in
//            XCTAssertEqual(error._code, TestFailure.error._code)
//        }
//    }

}
