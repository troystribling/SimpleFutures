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

// MARK: - Try -

public enum Try<T> {

    case Success(T)
    case Failure(ErrorType)
    
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
                return try Try<T>(recovery(error))
            } catch {
                return Try<T>(error)
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
                return Try<T>(error)
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

// MARK: - Try Sequence Type-

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

// MARK: - CompletionId -

public struct CompletionId : Hashable {

    let identifier = NSUUID()

    public var hashValue: Int {
        return identifier.hashValue
    }

}

public func ==(lhs: CompletionId, rhs: CompletionId) -> Bool {

    return lhs.hashValue == rhs.hashValue

}

// MARK: - Serial IO -

// MARK: SerialIODictionary

class SerialIODictionary<T, U where T: Hashable> {

    private var data = [T: U]()
    let queue: Queue

    init(_ queue: Queue) {
        self.queue = queue
    }

    var values: [U] {
        return queue.sync { return Array(self.data.values) }
    }

    var keys: [T] {
        return queue.sync { return Array(self.data.keys) }
    }

    var count: Int {
        return data.count
    }

    subscript(key: T) -> U? {
        get {
            return queue.sync { return self.data[key] }
        }
        set {
            queue.sync { self.data[key] = newValue }
        }
    }

    func removeValueForKey(key: T) -> U? {
        return queue.sync { self.data.removeValueForKey(key) }
    }

    func removeAll() {
        queue.sync { self.data.removeAll() }
    }

}

// MARK: SerialIOArray

class SerialIOArray<T> {

    private var _data = [T]()
    let queue: Queue

    init(_ queue: Queue) {
        self.queue = queue
    }

    var data: [T] {
        get {
            return queue.sync { return self._data }
        }
        set {
            queue.sync { self._data = newValue }
        }
    }

    var first: T? {
        return queue.sync { return self._data.first }
    }

    var count: Int {
        return data.count
    }

    subscript(i: Int) -> T {
        get {
            return queue.sync { return self._data[i] }
        }
        set {
            queue.sync { self._data[i] = newValue }
        }
    }

    func append(value: T) {
        queue.sync { self._data.append(value) }
    }

    func removeAtIndex(i: Int) -> T {
        return queue.sync { self._data.removeAtIndex(i) }
    }

    func map<M>(transform: T -> M) -> [M] {
        return queue.sync { return self._data.map(transform) }
    }

    func forEach(apply: T -> Void) {
        queue.sync {
            self._data.forEach { apply($0) }
        }
    }

}

// MARK: - CancelToken -

public struct CancelToken {

    let completionId = CompletionId()

}

// MARK: - Futuable -
public protocol Futurable {

    associatedtype T

    var result: Try<T>? { get }
    var completed: Bool { get }

    func complete(result: Try<T>)
    func success(value: T)
    func failure(error: ErrorType)
    
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

public final class Future<T> : Futurable {

    typealias OnComplete = Try<T> -> Void
    private var savedCompletions = SerialIODictionary<CompletionId, OnComplete>(Queue.simpleFutures)

    public private(set) var result: Try<T>? {
        willSet {
            assert(self.result == nil)
        }
    }

    public var completed: Bool {
        return result != nil
    }
    
    public init() {}

    // MARK: Complete

    public func complete(result: Try<T>) {
        self.result = result
        for complete in savedCompletions.values {
            complete(result)
        }
        savedCompletions.removeAll()
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>) {
        future.onComplete(context: context) { result in
            self.complete(result)
        }
    }

    public func success(value: T) {
        complete(Try(value))
    }

    public func failure(error: ErrorType) {
        complete(Try<T>(error))
    }

    public func completeWith(context context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>) {
        stream.onComplete(context: context) { result in
            self.complete(result)
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
            savedCompletions[cancelToken.completionId] = savedCompletion
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
        guard let _ = savedCompletions.removeValueForKey(cancelToken.completionId) else {
            return false
        }
        return true
    }

    // MARK: Future Combinators

    public func map<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> Try<M>) -> Future<M> {
        let future = Future<M>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.flatMap(mapping))
        }
        return future
    }
    
    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> Future<M>) -> Future<M> {
        let future = Future<M>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.completeWith(context: context, future: mapping(value))
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func andThen(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), complete: Try<T> -> Void) -> Future<T> {
        let future = Future<T>()
        future.onComplete(context: context, complete: complete)
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> Try<T>) -> Future<T> {
        let future = Future<T>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> Future<T>) -> Future<T> {
        let future = Future<T>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(context: context, future: recovery(error))
            }
        }
        return future
    }
    
    public func withFilter(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: T -> Bool) -> Future<T> {
        let future = Future<T>()
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    public func forEach(context context:ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: T -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            result.forEach(apply)
        }
    }
    
    // MARK: FutureStream Combinators

    internal func flatMap<M>(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> FutureStream<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                stream.completeWith(mapping(value), context: context)
            case .Failure(let error):
                stream.failure(error)
            }
        }
        return stream
    }
    
    internal func recoverWith(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> FutureStream<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                stream.success(value)
            case .Failure(let error):
                stream.completeWith(recovery(error), context: context)
            }
        }
        return stream
    }

}


// MARK: - StreamPromise -

public final class StreamPromise<T> {

    public let future: FutureStream<T>
    
    public init(capacity: Int = Int.max) {
        self.future = FutureStream<T>(capacity: capacity)
    }
    
    public func complete(result: Try<T>) {
        future.complete(result)
    }
    
    public func completeWith(future: Future<T>, context: ExecutionContext = QueueContext.futuresDefault) {
        self.future.completeWith(future, context: context)
    }
    
    public func success(value: T) {
        future.success(value)
    }
    
    public func failure(error: ErrorType) {
        future.failure(error)
    }
    
    public func completeWith(stream: FutureStream<T>, context: ExecutionContext = QueueContext.futuresDefault) {
        future.completeWith(stream, context: context)
    }

}

// MARK: - FutureStream -

public final class FutureStream<T> {

    private var futures = SerialIOArray<Future<T>>(Queue.simpleFutureStreams)
    private typealias InFuture = Future<T> -> Void
    private var savedCompletions = SerialIODictionary<CompletionId, InFuture>(Queue.simpleFutureStreams)

    private let capacity: Int

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
        for complete in savedCompletions.values {
            complete(future)
        }
    }

    internal func completeWith(stream: FutureStream<T>, context: ExecutionContext = QueueContext.futuresDefault) {
        stream.onComplete(context: context) { result in
            self.complete(result)
        }
    }

    internal func success(value: T) {
        complete(Try(value))
    }

    internal func failure(error: ErrorType) {
        complete(Try<T>(error))
    }

    internal func completeWith(future: Future<T>, context: ExecutionContext = QueueContext.futuresDefault) {
        future.onComplete(context: context) {result in
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

    public func onComplete(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), complete: Try<T> -> Void) {
        let futureComplete : InFuture = { future in
            future.onComplete(context: context, complete: complete)
        }
        savedCompletions[cancelToken.completionId] = futureComplete
        futures.forEach { futureComplete($0) }
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
        guard let _ = savedCompletions.removeValueForKey(cancelToken.completionId) else {
            return false
        }
        return true
    }

    // MARK: Combinators

    public func map<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> Try<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.flatMap(mapping))
        }
        return future
    }
    
    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> FutureStream<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.completeWith(mapping(value), context: context)
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func andThen(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), complete: Try<T> -> Void) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        future.onComplete(context: context, complete: complete)
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> Try<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> FutureStream<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(recovery(error), context: context)
            }
        }
        return future
    }
    
    public func withFilter(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: T -> Bool) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    public func forEach(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: T -> Void) {
        onComplete(context: context, cancelToken: cancelToken) { result in
            result.forEach(apply)
        }
    }

    // MARK: Future Combinators

    public func flatMap<M>(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: T -> Future<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.completeWith(mapping(value), context: context)
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    public func recoverWith(context context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: ErrorType -> Future<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity: capacity)
        onComplete(context: context, cancelToken: cancelToken) { result in
            switch result {
            case .Success(let value):
                future.success(value)
            case .Failure(let error):
                future.completeWith(recovery(error), context: context)
            }
        }
        return future
    }

}

