// Playground - noun: a place where people can play

import UIKit
import SimpleFutures

public enum Thing<T> {
    case Success(T)
    case Failure(NSError)
}

let value  = Thing<Bool>.Success(false)

switch value {
case .Success(let value):
    print("\(value)", false)
case .Failure(_):
    print("Failure")
}