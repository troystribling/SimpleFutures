//: Playground - noun: a place where people can play

import UIKit
import SimpleFutures

let result = future(1 < 2)

result.onSuccess(context: ImmediateContext()) { value in
    print("\(value)")
}

