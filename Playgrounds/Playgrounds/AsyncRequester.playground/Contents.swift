//: Playground - noun: a place where people can play

import UIKit
import SimpleFutures

class AsyncRequester {

    var completion: ((Int, Swift.Error?) -> Void)?

    func asyncRequest(completion: @escaping (Int, Swift.Error?) -> Void) {
        self.completion = completion
    }
}

extension AsyncRequester {

    func async() -> Future<Int> {
        return future(method: asyncRequest)
    }
    
}

let request = AsyncRequester()
let future = request.async()