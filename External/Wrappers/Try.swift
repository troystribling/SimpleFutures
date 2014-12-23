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
    struct FilterFailed {
        static let code = 1
        static let description = "Filter failed"
    }
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
                return .Failure(NSError(domain:TryError.domain, code:TryError.FilterFailed.code, userInfo:[NSLocalizedDescriptionKey:TryError.FilterFailed.description]))
            }
            return self
        case .Failure(let error):
            return self
        }
    }
    
    public func foreach<M>(mapping:T -> M) {
        switch self {
        case .Success(let box):
            box.map(mapping)
            return
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

public func map<M,T>(try:Try<T>, mapping:T -> M) -> Try<M> {
    return try.map(mapping)
}

public func flatmap<M,T>(try:Try<T>, mapping:T -> Try<M>) -> Try<M> {
    return try.flatmap(mapping)
}

public func recover<T>(try:Try<T>, recovery:NSError -> T) -> Try<T> {
    return try.recover(recovery)
}

public func recoverWith<T>(try:Try<T>, recovery:NSError -> Try<T>) -> Try<T> {
    return try.recoverWith(recovery)
}

public func filter<T>(try:Try<T>, predicate:T -> Bool) -> Try<T> {
    return try.filter(predicate)
}

