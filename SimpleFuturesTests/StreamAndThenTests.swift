//
//  StreamAndThenTests.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import XCTest
import SimpleFutures

class StreamAndThenTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulAndThen() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onSuccessExpectation = fulfillAfterCalled(2, message:"onSuccess future")
        let andThenExpectation = fulfillAfterCalled(2, message:"andThen")
        let onSuccessAndThenExpectation = fulfillAfterCalled(2, message:"onSuccess andThen future")
        stream.onSuccess {value in
            XCTAssert(value, "future onSuccess value invalid")
            onSuccessExpectation()
        }
        stream.onFailure {error in
            XCTAssert(false, "future onFailure called")
        }
        let andThen = stream.andThen {result in
            switch result {
            case .Success(let resultBox):
                andThenExpectation()
            case .Failure(let error):
                XCTAssert(false, "andThen Failure")
            }
        }
        andThen.onSuccess {value in
            XCTAssert(value, "andThen onSuccess value invalid")
            onSuccessAndThenExpectation()
        }
        andThen.onFailure {error in
            XCTAssert(false, "andThen onFailure called")
        }
        writeSuccesfulFutures(promise, true, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedAndThen() {
        let promise = StreamPromise<Bool>()
        let stream = promise.future
        let onFailureExpectation = fulfillAfterCalled(2, message:"onFailure future")
        let andThenExpectation = fulfillAfterCalled(2, message:"andThen")
        let onFailureAndThenExpectation = fulfillAfterCalled(2, message:"onFailure andThen future")
        stream.onSuccess {value in
            XCTAssert(false, "future onSuccess called")
        }
        stream.onFailure {error in
            onFailureExpectation()
        }
        let andThen = stream.andThen {result in
            switch result {
            case .Success(let resultBox):
                XCTAssert(false, "andThen Success")
            case .Failure(let error):
                andThenExpectation()
            }
        }
        andThen.onSuccess {value in
            XCTAssert(false, "andThen onSuccess called")
        }
        andThen.onFailure {error in
            onFailureAndThenExpectation()
        }
        writeFailedFutures(promise, 2)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
