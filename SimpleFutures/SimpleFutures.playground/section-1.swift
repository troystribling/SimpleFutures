// Playground - noun: a place where people can play

import UIKit
import SimpleFutures

public struct SimpleFuturesTestError {
    static let domain = "SimpleFuturesTest"
    static let testError = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Test Error"])
}

struct RequestData {
    let promise = StreamPromise<Int>(capacity:10)
    func request() -> FutureStream<Int> {
        return self.promise.future
    }
    func receiveResult(value:Int?) {
        if let value = value {
            self.promise.success(value)
        } else {
            self.promise.failure(SimpleFuturesTestError.testError)
        }
    }
}

let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataRequest.receiveResult(10)

dataFuture.onSuccess {value in
    println("value: \(value)")
}

dataFuture.onFailure {error in
    println("failed: \(error.description)")
}


