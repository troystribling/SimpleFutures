//
//  Future.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 7/5/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation

public struct SimpleFuturesError {
    static let domain = "SimpleFutures"
    static let futureCompleted      = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Future has been completed"])
    static let futureNotCompleted   = NSError(domain:domain, code:2, userInfo:[NSLocalizedDescriptionKey:"Future has not been completed"])
}

public struct SimpleFuturesException {
    static let futureCompleted = NSException(name:"Future complete error", reason: "Future previously completed.", userInfo:nil)
}

// Promise
public class Promise<T> {
    
    public let future = Future<T>()
    
    public init() {
    }
    
    public func completeWith(future:Future<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    public func completeWith(executionContext:ExecutionContext, future:Future<T>) {
        self.future.completeWith(executionContext, future:future)
    }
    
    public func complete(result:Try<T>) {
        self.future.complete(result)
    }
    
    public func success(value:T) {
        self.future.success(value)
    }

    public func failure(error:NSError)  {
        self.future.failure(error)
    }
    
}

// future construct
public func future<T>(computeResult:Void -> Try<T>) -> Future<T> {
    return future(QueueContext.global, computeResult)
}

public func future<T>(executionContext:ExecutionContext, calculateResult:Void -> Try<T>) -> Future<T> {
    let promise = Promise<T>()
    executionContext.execute {
        promise.complete(calculateResult())
    }
    return promise.future
}

// Future
public class Future<T> {
    
    private var result:Try<T>?
    
    internal let defaultExecutionContext: ExecutionContext  = QueueContext.main
    typealias OnComplete                                    = Try<T> -> Void
    private var saveCompletes                               = [OnComplete]()
    
    public init() {
    }
    
    // should be Futureable protocol
    public func onComplete(executionContext:ExecutionContext, complete:Try<T> -> Void) -> Void {
        Queue.simpleFutures.sync {
            let savedCompletion : OnComplete = {result in
                executionContext.execute {
                    complete(result)
                }
            }
            if let result = self.result {
                savedCompletion(result)
            } else {
                self.saveCompletes.append(savedCompletion)
            }
        }
    }
    
    // should be future mixin
    internal func complete(result:Try<T>) {
        Queue.simpleFutures.sync {
            if self.result != nil {
                SimpleFuturesException.futureCompleted.raise()
            }
            self.result = result
            for complete in self.saveCompletes {
                complete(result)
            }
            self.saveCompletes.removeAll()
        }
    }
    
    public func onComplete(complete:Try<T> -> Void) {
        self.onComplete(self.defaultExecutionContext, complete)
    }

    public func onSuccess(success:T -> Void) {
        self.onSuccess(self.defaultExecutionContext, success)
    }
    
    public func onSuccess(executionContext:ExecutionContext, success:T -> Void){
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let valueBox):
                success(valueBox.value)
            default:
                break
            }
        }
    }

    public func onFailure(failure:NSError -> Void) -> Void {
        return self.onFailure(self.defaultExecutionContext, failure)
    }
    
    public func onFailure(executionContext:ExecutionContext, failure:NSError -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }

    public func map<M>(mapping:T -> Try<M>) -> Future<M> {
        return map(self.defaultExecutionContext, mapping:mapping)
    }
    
    public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> Future<M> {
        let future = Future<M>()
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    public func flatmap<M>(mapping:T -> Future<M>) -> Future<M> {
        return self.flatmap(self.defaultExecutionContext, mapping:mapping)
    }

    public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> Future<M> {
        let future = Future<M>()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.completeWith(executionContext, future:mapping(resultBox.value))
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func andThen(complete:Try<T> -> Void) -> Future<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    public func andThen(executionContext:ExecutionContext, complete:Try<T> -> Void) -> Future<T> {
        let future = Future<T>()
        future.onComplete(executionContext, complete)
        self.onComplete(executionContext) {result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(recovery: NSError -> Try<T>) -> Future<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(recovery:NSError -> Future<T>) -> Future<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.success(resultBox.value)
            case .Failure(let error):
                future.completeWith(executionContext, future:recovery(error))
            }
        }
        return future
    }
    
    public func withFilter(filter:T -> Bool) -> Future<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    internal func completeWith(future:Future<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    internal func completeWith(executionContext:ExecutionContext, future:Future<T>) {
        let isCompleted = Queue.simpleFutures.sync {Void -> Bool in
            return self.result != nil
        }
        if isCompleted == false {
            future.onComplete(executionContext) {result in
                self.complete(result)
            }
        }
    }
    
    internal func success(value:T) {
        self.complete(Try(value))
    }
    
    internal func failure(error:NSError) {
        self.complete(Try<T>(error))
    }
    
}
