//
//  TestHelper.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import UIKit
import SimpleFutures

struct TestFailure {
    static let error = NSError(domain:"SimpleFutures Tests", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

func writeSuccesfulFutures<T>(promise:StreamPromise<T>, value:T, times:Int) {
    for i in (1...times) {
        promise.success(value)
    }
}

func writeFailedFutures<T>(promise:StreamPromise<T>, times:Int) {
    for i in (1...times) {
        promise.failure(TestFailure.error)
    }
}

