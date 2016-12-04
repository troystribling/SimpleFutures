[![Build Status](https://travis-ci.org/troystribling/SimpleFutures.svg?branch=master)](https://travis-ci.org/troystribling/SimpleFutures)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SimpleFutures.svg)](https://img.shields.io/cocoapods/v/SimpleFutures.svg)
[![Platform](https://img.shields.io/cocoapods/p/SimpleFutures.svg?style=flat)](http://cocoadocs.org/docsets/SimpleFutures)
[![License](https://img.shields.io/cocoapods/l/SimpleFutures.svg?style=flat)](http://cocoadocs.org/docsets/SimpleFutures)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![SimpleFutures: Scala Futures for Swift](https://cdn.rawgit.com/troystribling/SimpleFutures/67f65a62ac294a6e1068387c7d1ebaabf4883b49/Assets/banner.png)

A Swift implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) with extras.

# Motivation

`Futures` provide an interface for performing nonblocking asynchronous requests and combinator interfaces for serializing the processing of requests, error recovery and filtering. In most iOS libraries asynchronous interfaces are supported through the delegate-protocol pattern or in some cases with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. It will be seen that `Futures` very nicely solve this problem. 

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

# Futures

A `Future` instance is a `read-only` encapsulation of an immutable result that can be computed anytime in the future. When the result is computed the `Future` is said to be completed. A `Future` may be completed successfully with a value or failed with an error. 

A `Future` also has combinator methods that allow multiple instances to be chained together and executed serially and container methods are provided that can evaluate multiple `Futures` simultaneously.

Each of these topics are discussed in this section.

## Creation

A `Future` can be created using either the `future` method, a `Promise` or initializer. 

### `init`

`init` methods are provided that create a future with a specified result.

```swift
// create a future with an Int result
Future(value: 1)

// create a Future with an error result
Future<Int>(error: MyError.failed)
```

### `future`

Several versions of `future` are provided to facilitate integration with existing code.

The simplest takes an `@autoclosure` or closure that returns a result.

```swift
let result1 = future(1 < 2)

let result2 = future {
    return 1
}
```

Versions that take common completion block forms are also provided.

```swift

```

### `Promises`

A `Promise` instance is `one-time` writable and contains a `Future`. When completing its `Future` successfully a `Promise` will write a value to the `Future` result and when completing with failure will write an error to its `Future` result. 

`Future` interface implementations will use a `Promise` to create a 'Future`.

Here a simple `URLSession` `extension` is shown that adds a method performing `HTTP` `GET` request.

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

## completeWith

## Cancel

## Combinators

### map 

### flatMap

### withFilter

### forEach

### andThen

### recover

### recoverWith

### mapError

### fold

### sequence

# FutureStreams

In frameworks such as `CoreLocation` the `CLLocationManagerDelegate` method,

```swift
func locationManager(_ manager: CLLocationManager!,
           didUpdateLocations locations: [AnyObject]!)
```

can be called repeatedly for a single instantiation of `CLLocationManager`. Since `Futures` are immutable a new instance must be created for each call. `FutureStreams` are read-only completed `Future` containers that can be used to persist all past calls in situations such as this. `FutureStreams` support an interface similar to `Futures` and can be combined with them using combinators. 

## Creation

A `FutureStream` can be created using either the `futureStream` method, a `StreamPromise` or initializer. 

### `init`

`init` methods are provided that create a future with a specified result.

```swift
// create a future with an Int result and capacity of 10
FutureStream(value: 1, capacity: 10)

// create a Future with an error result and capacity of 10
FutureStream<Int>(error: MyError.failed, capacity: 10)
```

### `futureStream`

## `StreamPromises`

The `StreamPromise` like a `Promise` is `write-only` and additionally places completed futures in the `FutureStream` and provides the interface to add completed futures to a `FutureStream`.

`FutureStream` interface implementations will use a `StreamPromise` to create a 'FutureStream`.

Here a simple `Accelerometer` service is shown. `Accelerometer` data updates are provided through a `FutureStream`.
 
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

```swift
accelrometerDataFuture.onSuccess { data in
   // process data
}
accelrometerDataFuture.onFailure { error in
  // handle error
}
```

## completeWith

## Cancel

## Combinators

### map 

### flatMap

### withFilter

### forEach

### andThen

### recover

### recoverWith

### mapError

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

`SimpleFutures` provides the `QueueContext` which runs tasks asynchronously on the specified `Queue` and `ImmediateContext` which executes task synchronously on the calling thread.

```swift
// main and global queue contexts
QueueContext.main
QueueContext.global

// immediate context runs tasks synchronously on the calling thread
ImmediateContext()

// create a QueueContext using queue
public init(queue: Queue)
```

Completion handlers and combinators for both `Futures` and `FutureStreams` run within a specified context. The default context is `QueueContext.main`

`ImmediateContext()` can be useful for testing.

# Try

`Future` results are of type `Try`. A `Try` is similar to an [`Optional`](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html#//apple_ref/doc/uid/TP40014097-CH31-ID452) but instead of case `.none` has a failure case containing an `Swift.Error` object,

## Create

## Combinators

### map 

### flatMap

### filter

### forEach

### andThen

### recover

### recoverWith

### mapError

### orElse

### toOptional

### getOrElse

## Test Cases

[Test Cases](/Tests) are available. To build the `workspace`,

```bash
pod install
```

and run from `test` tab in generated `workspace`.

