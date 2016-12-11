[![Build Status](https://travis-ci.org/troystribling/SimpleFutures.svg?branch=master)](https://travis-ci.org/troystribling/SimpleFutures)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SimpleFutures.svg)](https://img.shields.io/cocoapods/v/SimpleFutures.svg)
[![Platform](https://img.shields.io/cocoapods/p/SimpleFutures.svg?style=flat)](http://cocoadocs.org/docsets/SimpleFutures)
[![License](https://img.shields.io/cocoapods/l/SimpleFutures.svg?style=flat)](http://cocoadocs.org/docsets/SimpleFutures)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![SimpleFutures: Scala Futures for Swift](https://cdn.rawgit.com/troystribling/SimpleFutures/67f65a62ac294a6e1068387c7d1ebaabf4883b49/Assets/banner.png)

A Swift implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) with extras.

# Motivation

`Futures` provide an interface for performing nonblocking asynchronous requests and combinator interfaces for serializing the processing of requests, error recovery and filtering. In most iOS libraries asynchronous interfaces are supported through the delegate-protocol pattern or with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow.  

SimpleFutures is an implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) in Swift and was influenced by [BrightFutures](https://github.com/Thomvis/BrightFutures).

# Requirements

- iOS 9.0+
- Xcode 8.1

# Installation

## CocoaPods

[CocoaPods](https://cocoapods.org) is an Xcode dependency manager. It is installed with the following command,

```bash
gem install cocoapods
```

> Requires CocoaPods 1.1+

Add `SimpleFutures` to your to your project `Podfile`,

```ruby
platform :ios, '9.0'
use_frameworks!

target 'Your Target Name' do
  pod 'SimpleFutures', '~> 0.2'
end
```

To enable `DBUG` output add this [`post_install` hook](https://gist.github.com/troystribling/2d4630200d3dd4e3fc8b6d5e14e4732a) to your `Podfile`

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Xcode projects.
It can be installed using [Homebrew](http://brew.sh/),

```bash
brew update
brew install carthage
```

To add `SimpleFutures` to your `Cartfile`

```ogdl
github "troystribling/SimpleFutures" ~> 0.2
```

To download and build `SimpleFutures.framework` run the command,

```bash
carthage update
```

then add `SimpleFutures.framework` to your project.

If desired use the `--no-build` option,

```bash
carthage update --no-build
```

This will only download `SimpleFutures`. Then follow the steps in [Manual](#manual) to add it to a project.

## Manual

1. Place the SimpleFutures somewhere in your project directory. You can either copy it or add it as a `git submodule`.
2. Open the SimpleFutures project folder and drag SimpleFutures.xcodeproj into the project navigator of your applications Xcode project.
3. Under your Projects *Info* tab set the *iOS Deployment Target* to 9.0 and verify that the SimpleFutures.xcodeproj *iOS Deployment Target* is also 9.0.
4. Under the *General* tab for your project target add the top SimpleFutures.framework as an *Embedded Binary*.
5. Under the *Build Phases* tab add SimpleFutures.framework as a *Target Dependency* and under *Link Binary With Libraries*.

Another option is to add `SimpleFutures.swift` directly to your project, since the entire library is contained in a single file.

# Queue

A simple wrapper around `GCD` is provided. 

```swift
// create a queue with .background pos
let queue = Queue("us.gnos.myqueue")

// run block synchronously on queue
queue.sync {
  // do something
}

// return a value from a synchronous task
let result = queue.sync {
  // do something
  return value
}

// run block asynchronously on queue
queue.async {
  // do something
}

// run block asynchronously at specified number of seconds from now
queue.delay(10.0) {
  // do something
}
```

# Execution Context

An `ExecutionContext` executes tasks and is defined by an implementation of the protocol,

```swift
public protocol ExecutionContext {
    func execute(task: Void -> Void)
}
```

`SimpleFutures` provides a `QueueContext` which runs tasks asynchronously on a specified `Queue` and `ImmediateContext` which executes task synchronously on the calling thread.

```swift
// main and global queue contexts
QueueContext.main
QueueContext.global

// create a QueueContext using queue
public init(queue: Queue)

// immediate context runs tasks synchronously on the calling thread
ImmediateContext()
```

Completion handlers and combinators for both `Futures` and `FutureStreams` run within a specified context. The default context is `QueueContext.main`

`ImmediateContext()` can be useful for testing.

# Future

A `Future` instance is a *read-only* encapsulation of an immutable *result* that can be computed anytime in the future. When the *result* is computed the `Future` is said to be *completed*. A `Future` may be *completed* successfully with a value or failed with an error. 

A `Future` also has combinator methods that allow multiple instances to be chained together and executed serially and container methods are provided that can evaluate multiple `Futures` simultaneously.

## Creation

A `Future` can be created using either the `future` method, a `Promise` or initializer. 

### `init`

`init` methods are provided that create a `Future<T>` with a specified result.

```swift
// create an uncompleted future
public init()

// create a future with result of type T
public init(value: T)

// create a Future with an error result
public init(error: Swift.Error)
```

### `future`

Several versions of `future` are provided to facilitate integration with existing code.

The simplest take a synchronous `@autoclosure` or closure,

```swift
// task is executed synchronously
public func future<T>( _ task: @autoclosure @escaping (Void) -> T) -> Future<T>

// task is executed in context which may be asynchronous
public func future<T>(context: ExecutionContext = QueueContext.futuresDefault, _ task: @escaping (Void) throws -> T) -> Future<T>
```

Versions that take an asynchronous closure parameter of common completion block types are also provided.

```swift
public func future<T>(method: (@escaping (T, Swift.Error?) -> Void) -> Void) -> Future<T>

public func future<T>(method: (@escaping (T, Swift.Error?) -> Void) -> Void) -> Future<T>

public func future<T>(method: (@escaping (T) -> Void) -> Void) -> Future<T>
```

Adding a `Future` interface to existing code is simple using `future`. Consider the following class with an asynchronous request taking a completion block,

```swift
class AsyncRequester {

    func request(completion: @escaping (Int?, Swift.Error?) -> Void)
    
}
```

An extension adding a `Future` interface would look like,

```swift
extension AsyncRequester {

    func futureRequest() -> Future<Int?> {
        return future(method: request)
    }

}
```

### `Promise`

A `Promise` instance is *one-time* writable and contains a `Future`. When *completing* its `Future` successfully a `Promise` will write a value to the `Future` result and when *completing* with failure will write an error to its `Future` result. 

```swift
// Create and uncompleted Promise
public init()

// Completed Promise with another Future
public func completeWith(context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>)
    
// Complete Promise successfully with value
public func success(_ value: T)

// Complete Promise with error
public func failure(_ error: Swift.Error)
```

`Future` interface implementations can use a `Promise` to create and manage the `Future`.

Here a simple `URLSession` `extension` is shown that adds a method performing an `HTTP` `GET` request returning a `Future`.

```swift
extension URLSession {

    class func get(with url: URL) -> Future<(Data?, URLResponse?)> {
        let promise = Promise<(Data?, URLResponse?)>()
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success((data, response))
            }
        }
        task.resume()
        return promise.future
    }

}
```

To use in an application,

```swift
let requestFuture = URLSession.get(with: URL(string: "http://troystribling.com")!)
```

## Handle Completion

Setting the value of a `Future` result *completes* it. The holder of a `Future` reference is notified of *completion* by the methods `onSuccess` and `onFailure`. The `requestFuture` of the previous section would handle *completion* events using,

```swift
requestFuture.onSuccess { (data, response) in
    guard let response = response, let data = data else {
        return
    }
    // process data
}

requestFuture.onFailure { error in
    // handle error
}
```

Multiple completion handlers can be defined for a single `Future`.

## completeWith

A `Future` can be *completed* with result of another `Future` using `completeWith`.

```swift
public func completeWith(context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>)
```

For example,

```swift
let anotherFuture = Future<Int>()
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

let dependentFuture = future(method: asyncRequest)
anotherFuture.completeWith(future: dependentFuture)
```

## Combinators

Combinators are methods used to construct a serialized chain of `Futures` that perform asynchronous requests and apply mappings and filters to request results. 

### map 

Apply a `mapping: (T) throws -> M` to the result of a successful `Future<T>` to produce a new `Future<M>`. 

```swift
public func map<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws -> M) -> Future<M>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

let mappedFuture = future(method: asyncRequest).map { value -> String in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return "\(value)"
}
``` 

### flatMap

Apply a `mapping: (T) throws -> Future<M>` to the result of a successful `Future<T>` returning `Future<M>`. `flatMap` is used to serialize asynchronous requests. 

```swift
public func flatMap<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws -> Future<M>) -> Future<M>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func asyncMapping(Int) -> Future<String>

let mappedFuture = future(method: asyncRequest).flatMap { value -> Future<String> in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return asyncMapping(value)
}
```

`flatMap` will usually require specification of the closure return type. It is an overloaded method and the compiler sometimes needs help in determining which to use.

### withFilter

Apply a `filter: (T) throws -> Bool` to the result of a successful `Future<T>` returning the `Future<T>` if the `filter` succeeds and `throwing` `FuturesError.noSuchElement` if the `filter` fails.

```swift
public func withFilter(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: @escaping (T) throws -> Bool) -> Future<T>
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

let filteredFuture = future(method: asyncRequest).withFilter { value in
    value > 0
}
```

### forEach

Apply a mapping `apply: (T) -> Void` to a successful `Future<T>`. This is equivalent to using the completion handler `onSuccess`.

```swift
public func forEach(context:ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: @escaping (T) -> Void)
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func apply(Int) -> Void

let forEachFuture = future(method: asyncRequest).forEach { value in
    apply(value)
}
```

### andThen

Apply a mapping `apply: (T) -> Void` to a successful `Future<T>` and return a `Future<T>` completed with the result of the original future. This is equivalent to a pass through. Here data can be processed in a combinator chain but not effect the `Future` `result`.

```swift
public func andThen(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), completion: @escaping (T) -> Void) -> Future<T>
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func apply(Int) -> Void

let andThenFuture = future(method: asyncRequest).andThen { value in
    apply(value)
}
```

### recover

Apply a recovery mapping `recovery: (Swift.Error) throws -> T` to a failed `Future<T>` returning a `Future<T>`.

```swift
public func recover(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: @escaping (Swift.Error) throws -> T) -> Future<T>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func recovery(Swift.Error) -> Int

let recoveryFuture = future(method: asyncRequest).recover { error in
    guard let appError = error as? AppError else {
        throw error
    }
    return recovery(appError)
}
```

### recoverWith

Apply a recovery mapping `recovery: (Swift.Error) throws -> Future<T>` to a failed `Future<T>` returning a `Future<T>`.

```swift
public func recoverWith(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: @escaping (Swift.Error) throws -> Future<T>) -> Future<T>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func recovery(Swift.Error) -> Future<Int>

let recoveryFuture = future(method: asyncRequest).recoverWith { error -> Future<Int> in
    guard let appError = error as? AppError else {
        throw error
    }
    return recovery(appError)
}
```

`recoverWith` will usually require specification of the closure return type. It is an overloaded method and the compiler sometimes needs help in determining which to use.

### mapError

Apply a mapping `mapping: (Swift.Error) -> Swift.Error` to a failed `Future<T>` and return a `Future<T>` with the new error result.

```swift
public func mapError(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (Swift.Error) -> Swift.Error) -> Future<T>
```

For example, to convert any `Swift.Error` to an `AppError`,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func mapping(Swift.Error) -> AppError.Error

let mapErrorFuture = future(method: asyncRequest).mapError { error in
    guard let appError = error as? AppError else {
        return mapping(error)
    }
    return appError
}
```

### fold

Apply a `mapping: (R, Iterator.Element.T) throws -> R` to an array `[Future<T>]` accumulating the results into a new `Future<R>`. If any `Future<T>` fails `Future<R>` fails.

```swift
 public func fold<R>(context: ExecutionContext = QueueContext.futuresDefault, initial: R,  combine: @escaping (R, Iterator.Element.T) throws -> R) -> Future<R> 
```

For example,

```swift
func asyncTask(Int) -> Future<Int>

let futures = [asyncTask(1), asyncTask(1), asyncTask(1)] 

let foldFuture = futures.fold(initial: 0) { $0 + $1 } 
```

### sequence

Transform `[Future<T>]` to `Future<[T]>` which completes with an array all results when all `[Future<T>]` completes. `sequence` is used to accumulate the result of unrelated asynchronous requests.

```swift
public func sequence(context: ExecutionContext = QueueContext.futuresDefault) -> Future<[Iterator.Element.T]>
```

For example,

```swift
fun asyncTask(Int) -> Future<Int>

let futures = [asyncTask(1), asyncTask(1), asyncTask(1)] 

let sequenceFuture = futures.sequence() 
```

## cancel

A `Future` can be passed around an application to notify different components of an event. Multiple completion handler definitions and combinator chains can be specified. Not all application components will maintain an interest in the event and may want to *unsubscribe*.

An application can `cancel` multiple completion handler callbacks and combinator executions using a `CancelToken()`.

```swift
fun asyncRequest() -> Int
fun anotherAsyncRequest() -> Future<String>

let cancelToken = CancelToken()
let cancelFuture = future(method: asyncRequest)

let mappedFuture = cancelFuture.flatMap(cancelToken: cancelToken) {
    anotherAsyncRequest()
}

mappedFuture.onSuccess(cancelToken: cancelToken) { value in
    // process data
}

mappedFuture.onFailure(cancelToken: cancelToken) { ==error in
    // process data
}

cancelFuture.cancel(cancelToken)
```

# FutureStream

In frameworks such as `CoreLocation` some `CLLocationManagerDelegate` methods can be called repeatedly for a single instantiation of `CLLocationManager`. For example,

```swift
func locationManager(_ manager: CLLocationManager!,
           didUpdateLocations locations: [AnyObject]!)
```

Since `Futures` are immutable a new instance must be created for each call. `FutureStreams` are read-only completed `Future` containers that can be used to persist all past calls up to a specified capacity in situations such as this. `FutureStreams` support an interface similar to `Futures` and can be combined with them using combinators. 

## Creation

A `FutureStream` can be created using either the `futureStream` method, a `StreamPromise` or initializer. 

### `init`

`init` methods are provided that create a future with a specified result.

```swift
// create an empty FutureStream with capacity
public init(capacity: Int)

// create a FutureStream with an Int result and capacity of 10
public init(value: T, capacity: Int)

// create a FutureStream with an error result and capacity of 10
public init(error: Swift.Error, capacity: Int)
```

### `futureStream`

Several versions of `futureStream` are provided to facilitate integration with existing code. 

The simplest takes a synchronous closure and executes it in the specified context.

```swift
public func futureStream<T>(context: ExecutionContext = QueueContext.futuresDefault, _ task: @escaping (Void) throws -> T) -> FutureStream<T>
```

Versions that take a closure parameter of a common completion block types are also provided.

```swift
public func futureStream<T>(method: (@escaping (T, Swift.Error?) -> Void) -> Void) -> FutureStream<T> 

public func futureStream(method: (@escaping (Swift.Error?) -> Void) -> Void) -> FutureStream<Void>

public func futureStream<T>(method: (@escaping (T) -> Void) -> Void) -> FutureStream<T>
```

Adding a `FutureStream` interface to existing code is simple using `futureStream`. Consider the following class with an asynchronous request taking a completion block,

```swift
class TestStreamRequester {

    func request(completion: @escaping (Int?, Swift.Error?) -> Void)}

}

extension TestStreamRequester {

    func streamRequest() -> FutureStream<Int?> {
        return futureStream(method: request)
    }
    
}
```

## `StreamPromise`

The `StreamPromise` like a `Promise` is *write-only*. It creates and *completes* `Futures` and adds them to the `FutureStream`.
 

```swift
// Create and uncompleted StreamPromise with capacity
public init(capacity: Int = Int.max)

// Complete StreamPromise with another Future
public func completeWith(context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>)
    
// Complete StreamPromise with another FutureStream
public func completeWith(context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>)
    
// Complete StreamPromise successfully with value
public func success(_ value: T)

// Complete StreamPromise with error
public func failure(_ error: Swift.Error)
```

`FutureStream` interface implementations can use a `StreamPromise` to create a `FutureStream`.

Here a simple `Accelerometer` service implementation is shown. `Accelerometer` data updates are provided through a `FutureStream`.
 
```swift
import UIKit
import CoreMotion
import BlueCapKit

class Accelerometer {

    var motionManager = CMMotionManager()
    let queue = OperationQueue.main
    let accelerationDataPromise = StreamPromise<CMAcceleration>(capacity: 10)
    
    var updatePeriod: TimeInterval {
        get {
            return motionManager.accelerometerUpdateInterval
        }
        set {
            motionManager.accelerometerUpdateInterval = newValue
        }
    }
    
    var accelerometerActive: Bool {
        return motionManager.isAccelerometerActive
    }
    
    var accelerometerAvailable: Bool {
        return motionManager.isAccelerometerAvailable
    }

    init() {
        motionManager.accelerometerUpdateInterval = 1.0
    }

    func startAcceleromterUpdates() -> FutureStream<CMAcceleration> {
        motionManager.startAccelerometerUpdates(to: queue) { [unowned self] (data: CMAccelerometerData?, error: Error?) in
            if let error = error {
                self.accelerationDataPromise.failure(error)
            } else {
                if let data = data {
                    self.accelerationDataPromise.success(data.acceleration)
                }
            }
        }
        return accelerationDataPromise.stream
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
```

To use in an application,

```swift
let accelerometer = Accelerometer()

let accelrometerDataFuture = accelerometer.startAcceleromterUpdates()
```

## Handle Completion

Adding a *completed* `Future` to  `FutureStream` calls its *completion* handlers. The holder of a `FutureStream` reference is notified when a *completed* `Future` is added to `FutureStream` by the methods `onSuccess` and `onFailure`. The `accelrometerDataFuture `of the previous section would handle *completion* events using,

```swift
accelrometerDataFuture.onSuccess { data in
   // process data
}

accelrometerDataFuture.onFailure { error in
  // handle error
}
```

Multiple completion handlers can be defined for a single `FutureStream`.

## completeWith

A `FutureStream` can be completed with result of another `Future` or `FutureStream` using `completeWith`.

```swift
func completeWith(context: ExecutionContext = QueueContext.futuresDefault, stream: FutureStream<T>)

func completeWith(context: ExecutionContext = QueueContext.futuresDefault, future: Future<T>)
```

For example,

```swift
let anotherFutureStream = FutureStream<Int>()
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

// Complete FutureStream with dependent Future
let dependentFuture = future(method: asyncRequest)
anotherFutureStream.completeWith(future: dependentFuture)

// Complete FutureStream with dependent FutureStream
let dependentStream = futureStream(method: asyncRequest)
anotherFutureStream.completeWith(future: dependentStream)
```

## Combinators

Combinators are methods used to construct a serialized chain of `FutureStreams` that perform asynchronous requests and apply mappings and filters.

### map 

Apply a `mapping: (T) throws -> M` to the result of a successful `FutureStream<T>` to produce a new `FutureStream<M>` of a different type.

```swift
public func map<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws -> M) -> FutureStream<M>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

let mappedStream = futureStream(method: asyncRequest).map { value -> String in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return "\(value)"
}
```

`mapping` is called each time the dependent `FutureStream` completes successfully.

### flatMap

Apply a `futureMapping: (T) throws -> Future<M>` or `streamMapping: (T) throws -> FutureStream<M>`  to the result of a successful `FutureStream<T>` returning `FutureStream<M>`. `flatMap` is used to serialize asynchronous requests and streams.

```swift
// Apply a mapping to a FutureStream returning a FutureStream
public func flatMap<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws -> FutureStream<M>) -> FutureStream<M>

// Apply a mapping to a FutureStream returning a Future
public func flatMap<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws  -> Future<M>) -> FutureStream<M>
```
 
For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func streamMapping(Int) -> FutureStream<String>

let mappedStream = futureStream(method: asyncRequest).flatMap { value -> FutureStream<String> in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return streamMapping(value)
}
```

and,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func futureMapping(Int) -> Future<String>

let mappedStream = futureStream(method: asyncRequest).flatMap { value -> Future<String> in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return futureMapping(value)
}
```

A mapping `streamMapping: (T) throws -> FutureStream<M>` can also be applied to the result of a successful `Future<T>`, returning a `FutureStream<M>`.

```swift
// Apply a mapping to Future returning a FutureStream
public func flatMap<M>(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws -> FutureStream<M>) -> FutureStream<M>   
```

For example,

```swift
let mappedStream = futureStream(method: asyncRequest).flatMap { value -> FutureStream<String> in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return streamMapping(value)
}
```

`flatMap` will usually require specification of the closure return type. It is an overloaded method and the compiler sometimes needs help in determining which to use.

### withFilter

Apply a `filter: (T) throws -> Bool` to the result of a successful `FutureStream<T>` returning the `FutureStream<T>` if the filter succeeds and `throwing` `FuturesError.noSuchElement` if the filter fails.

```swift
public func withFilter(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), filter: @escaping (T) throws  -> Bool) -> FutureStream<T>
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)

let filteredStream = futureStream(method: asyncRequest).withFilter { value in
    value > 0
}
```

### forEach

Apply a mapping `apply: (T) -> Void` to a successful `FutureStream<T>`. This is equivalent to using the completion handler `onSuccess`.

```swift
public func forEach(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), apply: @escaping (T) -> Void)
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func apply(Int) -> Void

let forEachStream = futureStream(method: asyncRequest).forEach { value in
    apply(value)
}
```

### andThen

Apply a mapping `apply: (T) -> Void` to a successful `FutureStream<T>` and return a `FutureStream<T>` completed with the result of the original stream. This is equivalent to a pass through. Here data can be processed in a combinator chain but not effect the `FutureStream<T>` result.

```swift
public func andThen(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), completion: @escaping (T) -> Void) -> FutureStream<T>
```

For example,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func apply(Int) -> Void

let andThenStream = futureStream(method: asyncRequest).andThen { value in
    apply(value)
}
```

### recover

Apply a recovery mapping `recovery: (Swift.Error) throws -> T` to a `FutureStream<T>` failure returning a `FutureStream<T>`.

```swift
public func recover(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: @escaping (Swift.Error) throws -> T) -> FutureStream<T>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func recovery(Swift.Error) -> Int

let recoveryStream = futureStream(method: asyncRequest).recover { error in
    guard let appError = error as? AppError else {
        throw error
    }
    return recovery(appError)
}
```

### recoverWith

Apply a recovery mapping `futureRecovery: (Swift.Error) throws -> Future<T>` or `streamRecovery: (Swift.Error) throws -> FutureStream<T>` to a `FutureStream<T>` failure returning a `FutureStream<T>`.

```swift
// Apply a recovery to a FutureStream returning a FutureStream
public func recoverWith(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: @escaping (Swift.Error) throws -> FutureStream<T>) -> FutureStream<T>
 
// Apply a recovery to a FutureStream returning a Future
public func flatMap<M>(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (T) throws  -> Future<M>) -> FutureStream<M>
```

For example,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func streamRecovery(Swift.Error) -> FutureStream<Int>

let recoveryStream = futureStream(method: asyncRequest).recoverWith { error -> FutureStream<Int> in
    guard let appError = error as? AppError else {
        throw error
    }
    return streamRecovery(appError)
}
```

and,

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func futureRecovery(Swift.Error) -> Future<Int>

let recoveryStream = futureStream(method: asyncRequest).recoverWith { value -> Future<String> in
    guard value < 0 else {
        throw AppError.invalidValue
    }
    return futureRecovery(value)
}
```

A `streamRecovery: (Swift.Error) throws -> FutureStream<T>` can also be applied to a failed `Future<T>`, returning a `FutureStream<M>`.

```swift
public func recoverWith(capacity: Int = Int.max, context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), recovery: @escaping (Swift.Error) throws -> FutureStream<T>) -> FutureStream<T>
```

For example,

```swift
let recoveryStream = futureStream(method: asyncRequest).recoverWith { error -> FutureStream<Int> in
    guard let appError = error as? AppError else {
        throw error
    }
    return streamRecovery(appError)
}
```

`recoverWith` will usually require specification of the closure return type. It is an overloaded method and the compiler sometimes needs help in determining which to use.

### mapError

Apply a mapping `mapping: (Swift.Error) -> Swift.Error` to a `FutureStream<T>` failure and return a `FutureStream<T>` with the mapped error result.

```swift
public func mapError(context: ExecutionContext = QueueContext.futuresDefault, cancelToken: CancelToken = CancelToken(), mapping: @escaping (Swift.Error) -> Swift.Error) -> FutureStream<T>
```

For example, to convert any `Swift.Error` to an `AppError`,

```swift
enum AppError: Error {
    case invalidValue
}

func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
func mapping(Swift.Error) -> AppError

let mapErrorStream = futureStream(method: asyncRequest).mapError { error in
    guard let appError = error as? AppError else {
	      return mapping(error)
    }
    return appError
}
```

## cancel

A `FutureStream` can be passed around an application to notify different components of an event. Multiple completion handler definitions and combinator chains can be specified. Not all application components will maintain an interest in the event and may want to 'unsubscribe'.

An application can `cancel` multiple completion handler callbacks and combinator executions using a `CancelToken()`.

```swift
func asyncRequest(_ completion: @escaping (Int, Swift.Error?) -> Void)
fun asyncStream() -> FutureStream<String>

let cancelToken = CancelToken()
let cancelStream = futureStream(method: asyncRequest)

let mappedStream = cancelStream.flatMap(cancelToken: cancelToken) {
    asyncStream()
}

mappedStream.onSuccess(cancelToken: cancelToken) { value in
    // process data
}

mappedStream.onFailure(cancelToken: cancelToken) { ==error in
    // process data
}

cancelFuture.cancel(cancelToken)
```

# Test Cases

[Test Cases](/Tests) are available. To build the `workspace`,

```bash
pod install
```

and run from `test` tab in generated `workspace`.

# Projects

The following projects use [SimpleFutures](https://github.com/troystribling/SimpleFutures). They can be used as guides in real application usage.

1. [BlueCap](https://github.com/troystribling/BlueCap) provides a `Futures` based replacement for CoreBluetooth.
2. [FutureLocation](https://github.com/troystribling/FutureLocation) provides a `Futures` based replacement for CoreLocation.
