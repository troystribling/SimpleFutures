//
//  Try.swift
//  Wrappers
//
//  Created by Troy Stribling on 12/21/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation

struct TryError {
    static let domain = "Wrappers"
    static let filterFailed = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Filter failed"])
}

public enum Try<T> {

    case Success(Box<T>)
    case Failure(NSError)
    
    public init(_ value:T) {
        self = .Success(Box(value))
    }

    public init(_ value:Box<T>) {
        self = .Success(value)
    }

    public init(_ error:NSError) {
        self = .Failure(error)
    }
    
    
    public mutating func failed(error:NSError) {
        self = .Failure(error)
    }
    
    public func isSuccess() -> Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    public func isFailure() -> Bool {
        switch self {
        case .Success:
            return false
        case .Failure:
            return true
        }
    }
    
    public func map<M>(mapping:T -> M) -> Try<M> {
        switch self {
        case .Success(let box):
            return Try<M>(box.map(mapping))
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func flatmap<M>(mapping:T -> Try<M>) -> Try<M> {
        switch self {
        case .Success(let box):
            return mapping(box.value)
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func recover(recovery:NSError -> T) -> Try<T> {
        switch self {
        case .Success:
            return self
        case .Failure(let error):
            return Try(recovery(error))
        }
    }
    
    public func recoverWith(recovery:NSError -> Try<T>) -> Try<T> {
        switch self {
        case .Success:
            return self
        case .Failure(let error):
            return recovery(error)
        }
    }
    
    public func filter(predicate:T -> Bool) -> Try<T> {
        switch self {
        case .Success(let box):
            if !predicate(box.value) {
                return .Failure(TryError.filterFailed)
            }
            return self
        case .Failure(let error):
            return self
        }
    }
    
    public func foreach(apply:T -> Void) {
        switch self {
        case .Success(let box):
            apply(box.value)
        case .Failure:
            return
        }
    }
    
    public func toOptional() -> Optional<T> {
        switch self {
        case .Success(let box):
            return Optional<T>(box.value)
        case .Failure(let error):
            return Optional<T>()
        }
    }
    
    public func getOrElse(failed:T) -> T {
        switch self {
        case .Success(let box):
            return box.value
        case .Failure(let error):
            return failed
        }
    }
    
    public func orElse(failed:Try<T>) -> Try<T> {
        switch self {
        case .Success(let box):
            return self
        case .Failure(let error):
            return failed
        }
    }
    
}


