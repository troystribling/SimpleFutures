//
//  SimpleFutures.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 5/25/15.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import Foundation

// MARK: - Errors -

enum SimpleFuturesErrors: Int, ErrorType {

    case futureCompleted = 0
    case futureNotCompleted = 1
    case filterFailed = 2

}

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

// MARK: - Tryable -
public protocol Tryable {
    associatedtype T

    var value: T? { get }
    var error: ErrorType? { get }

    init(_ value: T)
    init(_ error: ErrorType)

}

// MARK: - Try -

public enum Try<T>: Tryable {

    case Success(T)
    case Failure(ErrorType)

    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }

    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }

    public init(_ value: T) {
        self = .Success(value)
    }
    
    public init(_ error: ErrorType) {
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
    public func map<M>(@noescape mapping: T throws -> M) -> Try<M> {
        switch self {
        case .Success(let value):
            do {
                return try Try<M>(mapping(value))
            } catch {
                return Try<M>(error)
            }
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func flatMap<M>(@noescape mapping: T throws -> Try<M>) -> Try<M> {
        switch self {
        case .Success(let value):
            do {
                return try mapping(value)
            } catch {
                return Try<M>(error)
            }
        case .Failure(let error):
            return Try<M>(error)
        }
    }
    
    public func recover(@noescape recovery: ErrorType throws -> T) -> Try<T> {
        switch self {
        case .Success(let value):
            return Try(value)
        case .Failure(let error):
            do {
                return try Try(recovery(error))
            } catch {
                return Try(error)
            }
        }
    }

    public func recoverWith(@noescape recovery: ErrorType throws -> Try<T>) -> Try<T> {
        switch self {
        case .Success(let value):
            return Try(value)
        case .Failure(let error):
            do {
                return try recovery(error)
            } catch {
                return Try(error)
            }
        }
    }
    
    public func filter(@noescape predicate: T throws -> Bool) -> Try<T> {
        switch self {
        case .Success(let value):
            do {
                if try !predicate(value) {
                    return Try<T>(SimpleFuturesErrors.filterFailed)
                } else {
                    return .Success(value)
                }
            } catch {
                return Try<T>(error)
            }
        case .Failure(_):
            return self
        }
    }
    
    public func forEach(@noescape apply: T throws -> Void) {
        switch self {
        case .Success(let value):
            do {
                try apply(value)
            } catch {
                return
            }
        case .Failure:
            return
        }
    }

    public func orElse(failed: Try<T>) -> Try<T> {
        switch self {
        case .Success(let value):
            return Try(value)
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
    public func execute(task: Void->Void) {
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

// MARK: - CompletionId -

public struct CompletionId : Hashable {

    let identifier = NSUUID()

    public var hashValue: Int {
        return identifier.hashValue
    }

}

public func ==(lhs: CompletionId, rhs: CompletionId) -> Bool {

    return lhs.identifier == rhs.identifier

}

// MARK: - CancelToken -

public struct CancelToken {

    let completionId = CompletionId()

}

// MARK: - Futurable -

public protocol Futurable {
    typealias T

    var result: Try<T>? { get }

    init()
    init(_ result: T)
    init(_ dependent: Self)

    func complete(result: Try<T>)
    func onComplete(context context: ExecutionContext, cancelToken: CancelToken, complete: Try<T> -> Void) -> Void
}

public extension Futurable {

    //MARK: - Combinators -
    public func map<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws -> M) -> Future<M> {
        let future = Future<M>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.map(mapping))
        }
        return future
    }

    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws -> Future<M>) -> Future<M> {
        let future = Future<M>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.completeWith(context: context, future: result.map(mapping))
        }
        return future
    }

    public func recover(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws -> T) -> Future<T> {
        let future = Future<T>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.recover(recovery))
        }
        return future
    }

    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws -> Future<T>) -> Future<T> {
        let future = Future<T>()
        self.onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                do {
                    try future.completeWith(context: context, future: recovery(error))
                } catch {
                    future.failure(error)
                }
            }
        }
        return future
    }

    public func withFilter(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: T throws -> Bool) -> Future<T> {
        let future = Future<T>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.filter(filter))
        }
        return future
    }

    public func forEach(context context:ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: T throws -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            result.forEach(apply)
        }
    }
    
}

// MARK: - Promise -

public final class Promise<T> {

    public let future: Future<T>
    
    public var completed: Bool {
        return future.completed
    }
    
    public init() {
        self.future = Future<T>()
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        self.future.completeWith(context: context, future: future)
    }
    
    public func complete(result: Try<T>) {
        future.complete(result)
    }
    
    public func success(value: T) {
        future.success(value)
    }

    public func failure(error: ErrorType)  {
        future.failure(error)
    }

}

// MARK: - Future -

public final class Future<T>: Futurable {

    typealias OnComplete = Try<T> -> Void
    private var savedCompletions = [CompletionId : OnComplete]()
    private let queue = Queue("us.gnos.simpleFutures.main")

    public private(set) var result: Try<T>? {
        willSet {
            assert(self.result == nil)
        }
    }

    public var completed: Bool {
        return result != nil
    }

    public required init() {}

    public required init(_ result: T) {
        self.result = Try(result)
    }

    public required init(_ dependent: Future<T>) {
        completeWith(future: dependent)
    }

    // MARK: Complete

    public func complete(result: Try<T>) {
        self.result = result
        queue.sync {
            self.savedCompletions.values.forEach { $0(result) }
            self.savedCompletions.removeAll()
        }
    }

    public func success(value: T) {
        complete(Try(value))
    }

    public func failure(error: ErrorType) {
        complete(Try<T>(error))
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        future.onComplete(context: context) { result in
            self.complete(result)
        }
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>) {
        stream.onComplete(context: context) { result in
            self.complete(result)
        }
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Try<Future<T>>) {
        switch future {
        case .Success(let future):
            future.onComplete(context: context) { result in
                self.complete(result)
            }
        case .Failure(let error):
            failure(error)
        }
    }

    // MARK: Callbacks

    public func onComplete(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), complete: Try<T> -> Void) -> Void {
        let savedCompletion : OnComplete = { result in
            context.execute {
                    complete(result)
            }
        }
        if let result = result {
            savedCompletion(result)
        } else {
            queue.sync {
                self.savedCompletions[cancelToken.completionId] = savedCompletion
            }
        }
    }
    
    public func onSuccess(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), success: T -> Void){
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    public func onFailure(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), failure: ErrorType -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }

    public func cancel(cancelToken: CancelToken) -> Bool {
        return queue.sync {
            guard let _ = self.savedCompletions.removeValueForKey(cancelToken.completionId) else {
                return false
            }
            return true
        }
    }

    // MARK: FutureStream Combinators

    public func flatMap<M>(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws -> FutureStream<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.completeWith(context: context, stream: result.map(mapping))
        }
        return stream
    }
    
    public func recoverWith(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws -> FutureStream<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                stream.success(value)
            case .Failure(let error):
                do {
                    try stream.completeWith(context: context, stream: recovery(error))
                } catch {
                    stream.failure(error)
                }
            }
        }
        return stream
    }

}

// MARK: - Future SequenceType -

extension SequenceType where Generator.Element : Futurable {

    func fold<R>(context: ExecutionContext = QueueContext.futuresDefault, initial: R,  combine: (R, Generator.Element.T) -> R) -> Future<R> {
        return reduce(Future<R>(initial)) { accumulator, element in
            accumulator.flatMap(context: context) { accumulatorValue in
                return element.map(context: context) { elementValue in
                    return combine(accumulatorValue, elementValue)
                }
            }
        }
    }
}

// MARK: - StreamPromise -

public final class StreamPromise<T> {

    public let stream: FutureStream<T>
    
    public init(capacity: Int = Int.max) {
        stream = FutureStream<T>(capacity: capacity)
    }
    
    public func complete(result: Try<T>) {
        stream.complete(result)
    }
    
    public func success(value: T) {
        stream.success(value)
    }
    
    public func failure(error: ErrorType) {
        stream.failure(error)
    }
    
    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        stream.completeWith(context: context, future: future)
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>) {
        self.stream.completeWith(context: context, stream: stream)
    }

}

// MARK: - FutureStream -

public final class FutureStream<T> {

    public private(set) var futures = [Future<T>]()

    private typealias InFuture = Future<T> -> Void
    private var savedCompletions = [CompletionId : InFuture]()
    let queue = Queue("us.gnos.simpleFuturesStreams.main")

    private let capacity: Int

    public var count: Int {
        return futures.count
    }
    
    public init(capacity: Int = Int.max) {
        self.capacity = capacity
    }

    // MARK: Callbacks

    func complete(result: Try<T>) {
        let future = Future<T>()
        future.complete(result)
        queue.sync {
            if self.futures.count >= self.capacity  {
                self.futures.removeAtIndex(0)
            }
            self.futures.append(future)
            for complete in self.savedCompletions.values {
                complete(future)
            }
        }
    }

    func success(value: T) {
        complete(Try(value))
    }

    func failure(error: ErrorType) {
        complete(Try<T>(error))
    }

    func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>) {
        stream.onComplete(context: context) { result in
            self.complete(result)
        }
    }

    func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        future.onComplete(context: context) {result in
            self.complete(result)
        }
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, stream: Try<FutureStream<T>>) {
        switch stream {
        case .Success(let stream):
            stream.onComplete(context: context) { result in
                self.complete(result)
            }
        case .Failure(let error):
            failure(error)
        }
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Try<Future<T>>) {
        switch future {
        case .Success(let future):
            future.onComplete(context: context) { result in
                self.complete(result)
            }
        case .Failure(let error):
            failure(error)
        }
    }

    // MARK: Callbacks

    public func onComplete(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), complete: Try<T> -> Void) {
        let futureComplete : InFuture = { future in
            future.onComplete(context: context, complete: complete)
        }
        queue.sync {
            self.savedCompletions[cancelToken.completionId] = futureComplete
            self.futures.forEach { futureComplete($0) }
        }
    }

    public func onSuccess(context context:ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), success: T -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    public func onFailure(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), failure: ErrorType -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }

    public func cancel(cancelToken: CancelToken) -> Bool {
        return queue.sync {
            guard let _ = self.savedCompletions.removeValueForKey(cancelToken.completionId) else {
                return false
            }
            return true
        }
    }

    // MARK: Combinators

    public func map<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws -> M) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.complete(result.map(mapping))
        }
        return stream
    }
    
    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws -> FutureStream<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.completeWith(context: context, stream: result.map(mapping))
        }
        return stream
    }
    
    public func recover(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws -> T) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.complete(result.recover(recovery))
        }
        return stream
    }
    
    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws -> FutureStream<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                stream.success(value)
            case .Failure(let error):
                do {
                    try stream.completeWith(context: context, stream: recovery(error))
                } catch {
                    stream.failure(error)
                }
            }
        }
        return stream
    }
    
    public func withFilter(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: T throws  -> Bool) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.complete(result.filter(filter))
        }
        return stream
    }
    
    public func forEach(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: T throws -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            result.forEach(apply)
        }
    }

    // MARK: Future Combinators

    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T throws  -> Future<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            stream.completeWith(context: context, future: result.map(mapping))
        }
        return stream
    }
    
    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType throws  -> Future<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                stream.success(value)
            case .Failure(let error):
                do {
                    try stream.completeWith(context: context, future: recovery(error))
                } catch {
                    stream.failure(error)
                }
            }
        }
        return stream
    }

}

