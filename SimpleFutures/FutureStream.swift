//
//  FutureStream.swift
//  BlueCapKit
//
//  Created by Troy Stribling on 12/7/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation

public class StreamPromise<T> {

    public let future = FutureStream<T>()
    
    public init() {
    }
    
    public func success(value:T) {
        self.future.success(value)
    }
    
    public func failure(error:NSError) {
        self.future.failure(error)
    }
    
    public func complete(result:Try<T>) {
        self.future.complete(result)
    }
    
    public func completeWith(future:Future<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    public func completeWith(executionContext:ExecutionContext, future:Future<T>) {
        future.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
}

public class FutureStream<T> {
    
    private var futures                                     = [Future<T>]()
    private typealias InFuture                              = Future<T> -> Void
    private var saveCompletes                               = [InFuture]()
    
    internal let defaultExecutionContext: ExecutionContext  = QueueContext.main

    public init() {
    }
    
    public func onComplete(executionContext:ExecutionContext, complete:Try<T> -> Void) {
        Queue.simpleFutureStreams.sync {
            let futureComplete : InFuture = {future in
                future.onComplete(executionContext, complete)
            }
            self.saveCompletes.append(futureComplete)
            for future in self.futures {
                futureComplete(future)
            }
        }
    }

    public func onComplete(complete:Try<T> -> Void) {
        self.onComplete(self.defaultExecutionContext, complete)
    }
    
    public func onSuccess(success:T -> Void) {
        self.onSuccess(self.defaultExecutionContext, success:success)
    }

    public func onSuccess(executionContext:ExecutionContext, success:T -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                success(resultBox.value)
            default:
                break
            }
        }
    }

    public func onFailure(failure:NSError -> Void) {
        self.onFailure(self.defaultExecutionContext, failure:failure)
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
    
    public func map<M>(mapping:T -> Try<M>) -> FutureStream<M> {
        return self.map(self.defaultExecutionContext, mapping)
    }
    
    public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> FutureStream<M> {
        let future = FutureStream<M>()
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    public func flatmap<M>(mapping:T -> Future<M>) -> FutureStream<M> {
        return self.flatMap(self.defaultExecutionContext, mapping)
    }

    public func flatMap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> FutureStream<M> {
        let promise = StreamPromise<M>()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                promise.completeWith(executionContext, future:mapping(resultBox.value))
            case .Failure(let error):
                promise.failure(error)
            }
        }
        return promise.future
    }
    
    public func recover(recovery:NSError -> Try<T>) -> FutureStream<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> FutureStream<T> {
        let promise = StreamPromise<T>()
        self.onComplete(executionContext) {result in
            promise.complete(result.recoverWith(recovery))
        }
        return promise.future
    }
    
    public func andThen(complete:Try<T> -> Void) -> FutureStream<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    public func andThen(executionContext:ExecutionContext, complete:Try<T> -> Void) -> FutureStream<T> {
        let promise = StreamPromise<T>()
        promise.future.onComplete(executionContext, complete:complete)
        self.onComplete(executionContext) {result in
            promise.complete(result)
        }
        return promise.future
    }
    
    public func withFilter(filter:T -> Bool) -> FutureStream<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> FutureStream<T> {
        let promise = StreamPromise<T>()
        self.onComplete(executionContext) {result in
            promise.complete(result.filter(filter))
        }
        return promise.future
    }
    
    public func complete(result:Try<T>) {
        let future = Future<T>()
        future.complete(result)
        Queue.simpleFutureStreams.sync {
            self.futures.append(future)
            for complete in self.saveCompletes {
                complete(future)
            }
        }
    }
    
    public func completeWith(future:Future<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    public func completeWith(executionContext:ExecutionContext, future:Future<T>) {
        future.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    public func success(value:T) {
        self.complete(Try(value))
    }
    
    public func failure(error:NSError) {
        self.complete(Try<T>(error))
    }
    
}