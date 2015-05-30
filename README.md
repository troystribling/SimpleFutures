![SimpleFutures: Scala Futures for Swift](https://cdn.rawgit.com/troystribling/SimpleFutures/67f65a62ac294a6e1068387c7d1ebaabf4883b49/Assets/banner.png)

A Swift implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) with a few extras.

# Motivation

Futures provide the construction of code that processes asynchronous requests by default in a non-blocking and concise manner. They support combinator interfaces for serializing the processing of requests and for-comprehensions for processing requests in parallel. In addition combinators supporting error recovery and filtering are provided. In most Apple libraries asynchronous interfaces are supported through the delegate-protocol pattern or in some cases with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. It will be seen that Futures very nicely solve this problem. 

SimpleFutures is an implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) in Swift and was influenced by [BrightFutures](https://github.com/Thomvis/BrightFutures).

# Requirements

- iOS 8.0+
- Xcode 6.3+

# Installation

All code is contained in the single file SimpleFutures.swift. Add it to your project.

# Models


## Queue

A Queue instance wraps a [GCD Serial Queue](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html) and provides the methods,

```swift
// define main and global queue
public static let main = Queue(dispatch_get_main_queue());
public static let global = Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

// create with the specified name
public init(_ queueName:String)

// execute block synchronously
public func sync(block:Void -> Void)

// execute block synchronously and return a value of type T
public func sync<T>(block:Void -> T) -> T 

// execute block asynchronously
public func async(block:dispatch_block_t)
```

An application would create and run a task in a Queue using,

```swift
// create a queue
let sampleQueue = Queue("us.gnos.simpleFutures.example")

// run a task synchronously
sampleQueue.sync {
	…
}

// run a task synchronously and return a value
sampleQueue.sync {Void -> Bool
	…
	return true
}

// run a task asynchronously
sampleQueue.async {
	…
}
```

## Execution Context

An ExecutionContext executes tasks and is defined by and implementation of the protocol,

```swift
public protocol ExecutionContext {
    func execute(task:Void->Void)
}
```

SimpleFutures provides the QueueContext which runs tasks asynchronously on the specified Queue using,

```swift
// define main and global contetexts
public static let main =  QueueContext(queue:Queue.main)
public static let global = QueueContext(queue:Queue.global)

// create a QueueContext using queue
public init(queue:Queue)

// execute a task
public func execute(task:Void -> Void)
```

By default Futures execute on, QueueContext.main.

## Try

Future&lt;T&gt; results are of type Try&lt;T&gt;. A Try&lt;T&gt; is similar to an [Optional&lt;T&gt;](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html#//apple_ref/doc/uid/TP40014097-CH31-ID452) but instead of case None has a Failure case containing an NSError object,

```swift
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
}
```

The Box&lt;T&gt; is a workaround for a compiler bug.

## Futures, Promises, FutureStreams and StreamPromises

A Future instance is a read-only encapsulation of an immutable result that can be computed anytime in the future. When the result is computed the Future is said to be completed. A Future may be completed successfully with a value or failed with an error. A Promise instance is one-time writable and contains a Future. When completing its Future successfully a Promise will write a value to the Future result and when completing with failure will write an error to its Future result. 

In frameworks such as CoreLocation the CLLocationManagerDelegate method,

```swift
func locationManager(_ manager: CLLocationManager!,
           didUpdateLocations locations: [AnyObject]!)
```

can be called repeatedly for a single instantiation of CLLocationManager. Since Futures are immutable a new instance must be created for each call. FutureStreams are read-only completed Future containers that can be used to persist all past calls in situations such as this. FutureStreams support an interface similar to Futures and can be combined with them using combinators. The StreamPromise like a Promise is write-only and additionally places completed futures in the Future Stream. The following sections will provide more details about all models in the framework a describe the interfaces used to complete Futures.

The methods supported by Future, Promise, FutureStream and StreamPromise methods fall into four categories. Those that complete and create the future, callbacks, combinators and for-comprehensions. The following sections will describe each category and provide examples.
 
# Completing and Creating

Completing a future is synonymous with writing the result the Future&lt;T&gt; instance is immutable so publicly it is read only. If an attempt is made to complete a completed future a SimpleFuturesException is raised. The Future&lt;T&gt; methods used to create and and read the completion status are,

```swift
// true if future is completed
public var completed : Bool {get}

// create a future
public init()    
```

Promise&lt;T&gt; provides the interface to write a future result. The methods used are,

```swift
// true if future is completed		
public var completed : Bool {get} 
    
// get the future
public var future : Future<T> {get}

// create a promise
public init()
    
// complete the future with result 
public func complete(result:Try<T>)

// complete the future with another future result using the
// default execution context
public func completeWith(future:Future<T>)
    
// complete the future with another future result using the 
// specified execution context
public func completeWith(executionContext:ExecutionContext, future:Future<T>)
        
// complete the future successfully
public func success(value:T)
    
// complete the future with failure
public func failure(error:NSError)
```

An application can create and complete a future using,

```swift
let testError = NSError(domain:"Test", code:1, userInfo:[NSLocalizedDescriptionKey:"Test Error"])

struct RequestData {
	let promise = Promise<Int>()
	func request() -> Future<Int> {
	  return self.promise.future
	} 
	func receiveResult(value:Int?) {
		if let value = value {
	    self.promise.success(value)
	  } else {
	    self.promise.failure(SimpleFuturesTestError.testError)
		}
	}  
}

let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataRequest.receiveResult(10)
```

Completing a FutureStream&lt;T&gt; is synonymous to adding a completed Future&lt;T&lt;. It can have a finite capacity if specified in the constructor. The default value is infinite. The FutureStream&lt;T&gt; methods used to create and get the number of Future&lt;T&gt;s in the stream are,

```swift
// number of futures in stream
public var count : Int {get}

// create a stream with capacity
public init(capacity:Int?=nil)
```

StreamPromise&lt;T&gt; provides the interface to add completed futures to a FutureStream&lt;T&gt;. The methods used are,

```swift
// create a stream promise with capacity  
public init(capacity:Int?=nil)
    
// add a completed future to stream
public func complete(result:Try<T>)
    
// complete the stream with the result of another stream using
// default execution context
public func completeWith(stream:FutureStream<T>)
 
// complete the stream with the result of another stream using 
// specified execution context   
public func completeWith(executionContext:ExecutionContext, stream:FutureStream<T>)

// complete the stream with the result of a future using
// specified execution context
public func completeWith(future:Future<T>)
    
// complete the stream with the result of a future using 
// specified execution context
public func completeWith(executionContext:ExecutionContext, future:Future<T>)
    
// add a successfully completed future to the stream
public func success(value:T)
    
// add a failed completed future to the stream
public func failure(error:NSError) 
```

An application would create and complete a FutureStream&lt;T&gt; using,

```swift
let testError = NSError(domain:"Test", code:1, userInfo:[NSLocalizedDescriptionKey:"Test Error"])

struct RequestData {
    let promise = StreamPromise<Int>(capacity:10)
    func request() -> FutureStream<Int> {
        return self.promise.future
    }
    func receiveResult(value:Int?) {
        if let value = value {
            self.promise.success(value)
        } else {
            self.promise.failure(SimpleFuturesTestError.testError)
        }
    }
}

let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataRequest.receiveResult(10)
```

# future

# Callbacks

## onComplete

## onSuccess

## onFailure

# Combinators

## map

## flatmap

## recover

## recoverWith

## filter

## foreach

## andThen

# for comprehensions