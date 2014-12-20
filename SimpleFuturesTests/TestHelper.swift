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
    static let error = NSError(domain:"SimpleFutures", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

func writeSuccesfulFutures<T>(stream:FutureStream<T>, value:T) {
    let f1 = Future<T>()
    f1.success(value)
    let f2 = Future<T>()
    f2.success(value)
    stream.write(f1)
    stream.write(f2)
}

func writeFailedFutures<T>(stream:FutureStream<T>) {
    let f1 = Future<T>()
    f1.failure(TestFailure.error)
    let f2 = Future<T>()
    f2.failure(TestFailure.error)
    stream.write(f1)
    stream.write(f2)
}

