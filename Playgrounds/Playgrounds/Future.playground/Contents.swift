//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import SimpleFutures

enum PlaygroundError: Error {
    case failure
}

PlaygroundPage.current.needsIndefiniteExecution = true

// autoclosure only succeeds
let result1 = future(1 < 2)

result1.onSuccess(context: ImmediateContext()) { value in
    print(value)
}

// block success
let result2 = future(context: ImmediateContext()) { 1 }

result2.onSuccess(context: ImmediateContext()) { value in
    print(value)
}

// block success
let result3 = future(context: ImmediateContext()) { throw PlaygroundError.failure }

result3.onFailure(context: ImmediateContext()) { error in
    print(error)
}

// Completion block with value and error
var savedCompletion1: ((Int?, Swift.Error?) -> Void)?
func testMethod1(_ completion: @escaping (Int?, Swift.Error?) -> Void) {
    savedCompletion1 = completion
}
let result = future(method: testMethod1)
savedCompletion1!(1, nil)

