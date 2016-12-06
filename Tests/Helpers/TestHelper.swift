//
//  TestHelper.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import SimpleFutures

public enum TestFailure: Int, Swift.Error {
    case error
    case recoveryError
    case mappedError
}

struct TestContext {
    static let immediate = ImmediateContext()
}

class TestAsyncRequester {

    var completion: ((Int?, Swift.Error?) -> Void)!

    func request(completion: @escaping (Int?, Swift.Error?) -> Void) {
        self.completion = completion
    }

}

extension TestAsyncRequester {

    func futureRequest() -> Future<Int?> {
        return future(method: request)
    }

}


class TestStreamRequester {

    var completion: ((Int?, Swift.Error?) -> Void)!

    func request(completion: @escaping (Int?, Swift.Error?) -> Void) {
        self.completion = completion
    }

}

extension TestStreamRequester {

    func streamRequest() -> FutureStream<Int?> {
        return futureStream(method: request)
    }
    
}
