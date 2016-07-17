//
//  SimpleFutures.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 5/25/15.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import Foundation

// MARK: - Optional -
public extension Optional {
    
    func filter(predicate: Wrapped -> Bool) -> Wrapped? {
        switch self {
        case .Some(let value):
            return predicate(value) ? Optional(value) : nil
        case .None:
            return Optional()
        }
    }
    
    func forEach(apply: Wrapped -> Void) {
        switch self {
        case .Some(let value):
            apply(value)
        case .None:
            break
        }
    }
    
}

// MARK: - Try -
public struct TryError {
    public static let domain = "Wrappers"
    public static let filterFailed = NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Filter failed"])
}

public enum Try<T> {
    
    case Success(T)
    case Failure(NSError)
    
    public init(_ value:T) {
        self = .Success(value)
    }
    
    public init(_ error: NSError) {
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

    // MARK: Combinators
    public func map<M>(mapping: T -> M) -> Try<M> {
        switch self {
        case .Success(let value):
            return Try<M>(mapping(value))
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func flatMap<M>(mapping: T -> Try<M>) -> Try<M> {
        switch self {
        case .Success(let value):
            return mapping(value)
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func recover(recovery: NSError -> T) -> Try<T> {
        switch self {
        case .Success(let value):
            return Try(value)
        case .Failure(let error):
            return Try<T>(recovery(error))
        }
    }
    
    public func recoverWith(recovery: NSError -> Try<T>) -> Try<T> {
        switch self {
        case .Success(let value):
            return Try(value)
        case .Failure(let error):
            return recovery(error)
        }
    }
    
    public func filter(predicate: T -> Bool) -> Try<T> {
        switch self {
        case .Success(let value):
            if !predicate(value) {
                return Try<T>(TryError.filterFailed)
            } else {
                return Try(value)
            }
        case .Failure(_):
            return self
        }
    }
    
    public func forEach(apply: T -> Void) {
        switch self {
        case .Success(let value):
            apply(value)
        case .Failure:
            return
        }
    }

    public func orElse(failed: Try<T>) -> Try<T> {
        switch self {
        case .Success(let box):
            return Try(box)
        case .Failure(_):
            return failed
        }
    }

    // MARK: Coversion
    public func toOptional() -> Optional<T> {
        switch self {
        case .Success(let value):
            return Optional<T>(value)
        case .Failure(_):
            return Optional<T>()
        }
    }
    
    public func getOrElse(failed: T) -> T {
        switch self {
        case .Success(let value):
            return value
        case .Failure(_):
            return failed
        }
    }

}


// MARK: - ExecutionContext -
public protocol ExecutionContext {
    func execute(task:Void->Void)
}

public class ImmediateContext : ExecutionContext {
    public init() {}
    public func execute(task:Void->Void) {
        task()
    }
}

public struct QueueContext : ExecutionContext {
    public static var futuresDefault = QueueContext.main
    public static let main = QueueContext(queue: Queue.main)
    public static let global = QueueContext(queue: Queue.global)
    public let queue:Queue
    public init(queue: Queue) {
        self.queue = queue
    }
    public func execute(task: Void -> Void) {
        queue.async(task)
    }
}

// MARK: - Queue -
public struct Queue {
    public static let main = Queue(dispatch_get_main_queue());
    public static let global = Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    
    internal static let simpleFutures = Queue("us.gnos.simpleFutures.main")
    internal static let simpleFutureStreams = Queue("us.gnos.simpleFutures.streams")
    
    public let queue: dispatch_queue_t
    
    public init(_ queueName: String) {
        self.queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL)
    }
    
    public init(_ queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    public func sync(block: Void -> Void) {
        dispatch_sync(queue, block)
    }
    
    public func sync<T>(block: Void -> T) -> T {
        var result:T!
        dispatch_sync(queue, {
            result = block();
        });
        return result;
    }
    
    public func async(block: Void -> Void) {
        dispatch_async(queue, block);
    }
    
    public func delay(delay: NSTimeInterval, request: Void -> Void) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Float(delay)*Float(NSEC_PER_SEC)))
        dispatch_after(popTime, queue, request)
    }
}

// MARK: - Errors -
enum SimpleFuturesErrorCodes: Int {
    case FutureCompleted    = 0
    case FutureNotCompleted = 1
}

public struct SimpleFuturesError {
    static let domain               = "SimpleFutures"
    static let futureCompleted      = NSError(domain: domain, code: SimpleFuturesErrorCodes.FutureCompleted.rawValue, userInfo: [NSLocalizedDescriptionKey: "Future has been completed"])
    static let futureNotCompleted   = NSError(domain: domain, code: SimpleFuturesErrorCodes.FutureNotCompleted.rawValue, userInfo: [NSLocalizedDescriptionKey: "Future has not been completed"])
}

public struct SimpleFuturesException {
    static let futureCompleted = NSException(name: "Future complete error", reason: "Future previously completed.", userInfo: nil)
}

// MARK: - Promise -
public class Promise<T> {
    public let future: Future<T>
    
    public var completed: Bool {
        return future.completed
    }
    
    public init() {
        self.future = Future<T>()
    }

    public func completeWith(executionContext: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        self.future.completeWith(executionContext, future: future)
    }
    
    public func complete(result: Try<T>) {
        future.complete(result)
    }
    
    public func success(value: T) {
        future.success(value)
    }

    public func failure(error: NSError)  {
        future.failure(error)
    }
}

// MARK: - Future -
public class Future<T> {

    private var result: Try<T>?

    typealias OnComplete        = Try<T> -> Void
    private var saveCompletes   = [OnComplete]()

    public var completed: Bool {
        return result != nil
    }
    
    public init() {
    }

    // MARK: Complete
    internal func complete(result: Try<T>) {
        if self.result != nil {
            SimpleFuturesException.futureCompleted.raise()
        }
        self.result = result
        for complete in saveCompletes {
            complete(result)
        }
        saveCompletes.removeAll()
    }

    internal func completeWith(executionContext: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        if !completed {
            future.onComplete(executionContext) { result in
                self.complete(result)
            }
        }
    }

    internal func success(value: T) {
        complete(Try(value))
    }

    internal func failure(error: NSError) {
        complete(Try<T>(error))
    }

    internal func completeWith(executionContext: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>) {
        stream.onComplete(executionContext) { result in
            self.complete(result)
        }
    }

    // MARK: Callbacks
    public func onComplete(executionContext: ExecutionContext = QueueContext.futuresDefault, complete: Try<T> -> Void) -> Void {
        let savedCompletion : OnComplete = { result in
            executionContext.execute {
                complete(result)
            }
        }
        if let result = result {
            savedCompletion(result)
        } else {
            saveCompletes.append(savedCompletion)
        }
    }
    
    public func onSuccess(executionContext: ExecutionContext = QueueContext.futuresDefault, success: T -> Void){
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    public func onFailure(executionContext: ExecutionContext = QueueContext.futuresDefault, failure: NSError -> Void) {
        onComplete(executionContext) { result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }

    // MARK: Future Combinators
    public func map<M>(executionContext: ExecutionContext = QueueContext.futuresDefault, mapping: T -> Try<M>) -> Future<M> {
        let future = Future<M>()
        onComplete(executionContext) { result in
            future.complete(result.flatMap(mapping))
        }
        return future
    }
    
    public func flatMap<M>(executionContext: ExecutionContext = QueueContext.futuresDefault, mapping: T -> Future<M>) -> Future<M> {
        let future = Future<M>()
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.completeWith(executionContext, future: mapping(value))
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func andThen(executionContext: ExecutionContext = QueueContext.futuresDefault, complete: Try<T> -> Void) -> Future<T> {
        let future = Future<T>()
        future.onComplete(executionContext, complete: complete)
        onComplete(executionContext) { result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> Try<T>) -> Future<T> {
        let future = Future<T>()
        onComplete(executionContext) { result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> Future<T>) -> Future<T> {
        let future = Future<T>()
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(executionContext, future: recovery(error))
            }
        }
        return future
    }
    
    public func withFilter(executionContext: ExecutionContext = QueueContext.futuresDefault, filter: T -> Bool) -> Future<T> {
        let future = Future<T>()
        onComplete(executionContext) { result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    public func forEach(executionContext:ExecutionContext = QueueContext.futuresDefault, apply: T -> Void) {
        onComplete(executionContext) { result in
            result.forEach(apply)
        }
    }
    
    // MARK: FutureStream Combinators
    internal func flatMap<M>(capacity: Int = Int.max, executionContext: ExecutionContext = QueueContext.futuresDefault, mapping: T -> FutureStream<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                stream.completeWith(mapping(value), executionContext: executionContext)
            case .Failure(let error):
                stream.failure(error)
            }
        }
        return stream
    }
    
    internal func recoverWith(capacity: Int = Int.max, executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> FutureStream<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                stream.success(value)
            case .Failure(let error):
                stream.completeWith(recovery(error), executionContext: executionContext)
            }
        }
        return stream
    }
}


// MARK: - StreamPromise -
public class StreamPromise<T> {
    public let future: FutureStream<T>
    
    public init(capacity: Int = Int.max) {
        self.future = FutureStream<T>(capacity: capacity)
    }
    
    public func complete(result: Try<T>) {
        future.complete(result)
    }
    
    public func completeWith(future: Future<T>, executionContext: ExecutionContext = QueueContext.futuresDefault) {
        self.future.completeWith(future, executionContext: executionContext)
    }
    
    public func success(value: T) {
        future.success(value)
    }
    
    public func failure(error: NSError) {
        future.failure(error)
    }
    
    public func completeWith(stream: FutureStream<T>, executionContext: ExecutionContext = QueueContext.futuresDefault) {
        future.completeWith(stream, executionContext: executionContext)
    }
}

// MARK: - FutureStream -
public class FutureStream<T> {
    private var futures = [Future<T>]()
    private typealias InFuture = Future<T> -> Void

    private var saveCompletes = [InFuture]()
    private var capacity: Int

    public var count: Int {
        return futures.count
    }
    
    public init(capacity: Int = Int.max) {
        self.capacity = capacity
    }

    // MARK: Callbacks
    internal func complete(result: Try<T>) {
        let future = Future<T>()
        future.complete(result)
        addFuture(future)
        for complete in saveCompletes {
            complete(future)
        }
    }

    internal func completeWith(stream: FutureStream<T>, executionContext: ExecutionContext = QueueContext.futuresDefault) {
        stream.onComplete(executionContext) { result in
            self.complete(result)
        }
    }

    internal func success(value: T) {
        complete(Try(value))
    }

    internal func failure(error: NSError) {
        complete(Try<T>(error))
    }

    internal func completeWith(future: Future<T>, executionContext: ExecutionContext = QueueContext.futuresDefault) {
        future.onComplete(executionContext) {result in
            self.complete(result)
        }
    }

    internal func addFuture(future: Future<T>) {
        if futures.count >= capacity  {
            futures.removeAtIndex(0)
        }
        futures.append(future)
    }

    // MARK: Callbacks
    public func onComplete(executionContext: ExecutionContext = QueueContext.futuresDefault, complete: Try<T> -> Void) {
        let futureComplete : InFuture = { future in
            future.onComplete(executionContext, complete: complete)
        }
        saveCompletes.append(futureComplete)
        for future in futures {
            futureComplete(future)
        }
    }

    public func onSuccess(executionContext:ExecutionContext = QueueContext.futuresDefault, success: T -> Void) {
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    public func onFailure(executionContext: ExecutionContext = QueueContext.futuresDefault, failure: NSError -> Void) {
        onComplete(executionContext) { result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }

    // MARK: Combinators
    public func map<M>(executionContext: ExecutionContext = QueueContext.futuresDefault, mapping: T -> Try<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(executionContext) { result in
            future.complete(result.flatMap(mapping))
        }
        return future
    }
    
    public func flatMap<M>(executionContext:ExecutionContext = QueueContext.futuresDefault, mapping: T -> FutureStream<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.completeWith(mapping(value), executionContext: executionContext)
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func andThen(executionContext: ExecutionContext = QueueContext.futuresDefault, complete: Try<T> -> Void) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        future.onComplete(executionContext, complete: complete)
        onComplete(executionContext) { result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> Try<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(executionContext) { result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> FutureStream<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(recovery(error), executionContext: executionContext)
            }
        }
        return future
    }
    
    public func withFilter(executionContext: ExecutionContext = QueueContext.futuresDefault, filter: T -> Bool) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(executionContext) { result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    public func forEach(executionContext: ExecutionContext = QueueContext.futuresDefault, apply: T -> Void) {
        onComplete(executionContext) { result in
            result.forEach(apply)
        }
    }

    // MARK: Future Combinators
    public func flatMap<M>(executionContext: ExecutionContext = QueueContext.futuresDefault, mapping: T -> Future<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.completeWith(mapping(value), executionContext: executionContext)
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func recoverWith(executionContext: ExecutionContext = QueueContext.futuresDefault, recovery: NSError -> Future<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(executionContext) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(recovery(error), executionContext: executionContext)
            }
        }
        return future
    }

}

