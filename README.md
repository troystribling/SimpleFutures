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

## Wrapping Asynchronous Interfaces

## Handle Completion

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

# <a name="promises">Promises</a>

A `Promise` instance is `one-time` writable and contains a `Future`. When completing its Future successfully a `Promise` will write a value to the `Future` result and when completing with failure will write an error to its `Future` result. 

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

```swift
let requestFuture = URLSession.get(with: URL(string: "http://troystribling.com")!)

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

# <a name="future_streams">FutureStreamss</a>

In frameworks such as `CoreLocation` the `CLLocationManagerDelegate` method,

```swift
func locationManager(_ manager: CLLocationManager!,
           didUpdateLocations locations: [AnyObject]!)
```

can be called repeatedly for a single instantiation of `CLLocationManager`. Since `Futures` are immutable a new instance must be created for each call. `FutureStreams` are read-only completed `Future` containers that can be used to persist all past calls in situations such as this. `FutureStreams` support an interface similar to `Futures` and can be combined with them using combinators. 

## Wrapping Asynchronous Interfaces

## handle Completion

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

## <a name="stream_promises">StreamPromises</a>

The `StreamPromise` like a `Promise` is `write-only` and additionally places completed futures in the `FutureStream` and provides the interface to add completed futures to a `FutureStream`;.
 
```swift
// number of futures in stream
public var count : Int {get}

// create a stream with capacity
public init(capacity:Int?=nil)
```


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

```swift
let accelerometer = Accelerometer()

let accelrometerDataFuture = accelerometer.startAcceleromterUpdates()
           
accelrometerDataFuture.onSuccess { data in
   // process data
}
accelrometerDataFuture.onFailure { error in
  // handle error
}
```

# Queue

# Execution Context

An `ExecutionContext` executes tasks and is defined by and implementation of the protocol,

```swift
public protocol ExecutionContext {
    func execute(task:Void->Void)
}
```

`SimpleFutures` provides the `QueueContext` which runs tasks asynchronously on the specified `Queue` and `ImmediateContext` which executes task synchronously on the calling thread.

```swift
// define main and global contetexts
public static let main =  QueueContext(queue: Queue.main)
public static let global = QueueContext(queue: Queue.global)

// create a QueueContext using queue
public init(queue:Queue)

// execute a task
public func execute(task:Void -> Void)
```

By default `Futures` execute on, QueueContext.main.

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

