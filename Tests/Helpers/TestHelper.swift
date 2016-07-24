//
//  TestHelper.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import SimpleFutures

enum TestFailure : ErrorType {
    case error
}

func writeSuccesfulFutures<T>(promise:StreamPromise<T>, value:T, times:Int) {
    for _ in (1...times) {
        promise.success(value)
    }
}

func writeSuccesfulFutures<T>(promise:StreamPromise<T>, values:[T]) {
    for value in values {
        promise.success(value)
    }
}

func writeFailedFutures<T>(promise:StreamPromise<T>, times:Int) {
    for _ in (1...times) {
        promise.failure(TestFailure.error)
    }
}

struct TestContext {
    static let immediate = ImmediateContext()
}

