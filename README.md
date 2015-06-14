![SimpleFutures: Scala Futures for Swift](https://cdn.rawgit.com/troystribling/SimpleFutures/67f65a62ac294a6e1068387c7d1ebaabf4883b49/Assets/banner.png)

A Swift implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) with a few extras.

# <a name="motivation">Motivation</a>

Futures provide the construction of code that processes asynchronous requests by default in a non-blocking and concise manner. They support combinator interfaces for serializing the processing of requests, error recovery and filtering. In most Apple libraries asynchronous interfaces are supported through the delegate-protocol pattern or in some cases with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. It will be seen that Futures very nicely solve this problem. 

SimpleFutures is an implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) in Swift and was influenced by [BrightFutures](https://github.com/Thomvis/BrightFutures).

# <a name="requirements">Requirements</a>

- iOS 8.0+
- Xcode 6.3+

# <a name="installation">Installation</a>

All code is contained in the single file SimpleFutures.swift. Add it to your project.

# <a name="models">Models</a>

Here the models used in the framework will described and usage examples given.

## <a name="queue">Queue</a>

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

## <a name="execution_context">Execution Context</a>

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

## <a name="try">Try</a>

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

## <a name="futures_promises">Futures, Promises, FutureStreams and StreamPromises</a>

A Future instance is a read-only encapsulation of an immutable result that can be computed anytime in the future. When the result is computed the Future is said to be completed. A Future may be completed successfully with a value or failed with an error. A Promise instance is one-time writable and contains a Future. When completing its Future successfully a Promise will write a value to the Future result and when completing with failure will write an error to its Future result. 

In frameworks such as CoreLocation the CLLocationManagerDelegate method,

```swift
func locationManager(_ manager: CLLocationManager!,
           didUpdateLocations locations: [AnyObject]!)
```

can be called repeatedly for a single instantiation of CLLocationManager. Since Futures are immutable a new instance must be created for each call. FutureStreams are read-only completed Future containers that can be used to persist all past calls in situations such as this. FutureStreams support an interface similar to Futures and can be combined with them using combinators. The StreamPromise like a Promise is write-only and additionally places completed futures in the Future Stream. The following sections will provide more details about all models in the framework a describe the interfaces used to complete Futures.

The methods supported by Future, Promise, FutureStream and StreamPromise methods fall into four categories. Those that complete and create the future, callbacks, combinators and for-comprehensions. The following sections will describe each category and provide examples.
 
# <a name="completing_creating">Completing and Creating</a>

Completing a future is synonymous with writing the result. The Future&lt;T&gt; instance is immutable so publicly it is read only. If an attempt is made to complete a completed future a SimpleFuturesException is raised. The Future&lt;T&gt; methods used to create and and read the completion status are,

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

Completing a FutureStream&lt;T&gt; is synonymous to adding a completed Future&lt;T&lt; and it can have a finite capacity if specified in the constructor. The default value is infinite. The FutureStream&lt;T&gt; methods used to create and get the number of Future&lt;T&gt;s in the stream are,

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

# <a name="futures_promises">Callbacks</a>

Both Future&lt;T&gt; and FutureStream&lt;T&gt; have three callbacks that may be called on completion. They are,

```swift
// called when completed and executed in specified context
public func onComplete(executionContext:ExecutionContext, complete:Try<T> -> Void) 

// called when completed and executed in default context
public func onComplete(complete:Try<T> -> Void)

// called when successfully completed and executed in specified context 
public func onSuccess(executionContext:ExecutionContext, success:T -> Void)

// called when successfully completed and executed in default context 
public func onSuccess(success:T -> Void)

// called when completed with failure and executed in specified context 
public func onFailure(failure:NSError -> Void)

// called when completed with failure and executed in default context 
public func onFailure(executionContext:ExecutionContext, failure:NSError -> Void)
``` 

The following sections will provide more information and examples for each callback.

## <a name="oncomplete">onComplete</a>

The onComplete callback is called when a Future&lt;T&gt; or FutureStream&lt;T&gt; is completed and yields a Try&lt;T&gt; containing the result. For a Future&lt;T&gt;, using the [example](#completing_creating), an application would implement the callback using,

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onComplete {result in
	switch result {
	  case .Success(let result):
		  success(result.value)
		case .Failure(let error):
			failure(error)
	}
}
``` 

If Future&lt;T&gt; is completed prior to calling onComplete the callback will be called immediately, otherwise the it will be called when the future is later completed.

An application using a FutureStream&lt;T&gt; has a similar implementation using the same [example](#completing_creating) but the behavior will be different. 

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onComplete {result in
	switch result {
	  case .Success(let result):
		  mySuccess(result.value)
		case .Failure(let error):
			myFailure(error)
	}
}
``` 

Recall that a FutureStream&lt;T&gt; is a container of completed Future&lt;T&gt;s. When onComplete is called the callback will be called for all futures in the stream as well as all futures added to the stream in the future.

## <a name="onsuccess">onSuccess</a>

The onSuccess callback is called when a Future&lt;T&gt; or FutureStream&lt;T&gt; is completed successfully and yields the result of type T. For a Future&lt;T&gt;, using the [example](#completing_creating), an application would implement the callback using,

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onSuccess {result in
		…
	}
}
``` 

If Future&lt;T&gt; is completed prior to calling onSuccess the callback will be called immediately, otherwise the it will be called when the future is later completed. Also, onSuccess can be called multiple times using different callbacks.

An application using a FutureStream&lt;T&gt; has a similar implementation, using the same [example](#completing_creating), but the behavior will be different. 

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onSuccess {result in
		…
	}
}
``` 

Recall that a FutureStream&lt;T&gt; is a container of completed Future&lt;T&gt;s. When onSuccess is called the specified  callback will be executed for all successfully completed futures in the stream as well as all successfully completed futures added to the stream in the future. Also, onSuccess can be called multiple times using different callbacks.

## <a name="onfailure">onFailure</a>

The onError callback is called when a Future&lt;T&gt; or FutureStream&lt;T&gt; is completed with failure and yields the error of type NSError. For a Future&lt;T&gt;, using the [example](#completing_creating), an application would implement the callback using,

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onFailure {error in
		…
	}
}
``` 

If Future&lt;T&gt; is completed prior to calling onError the callback will be called immediately, otherwise the it will be called when the future is later completed. Also, onError can be called multiple times using different callbacks.

An application using a FutureStream&lt;T&gt; has a similar implementation, using the same [example](#completing_creating), but the behavior is different. 

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onFailure {error in
		…
	}
}
``` 

Recall that a FutureStream&lt;T&gt; is a container of completed Future&lt;T&gt;s. When onFailure is called the specified callback will be executed for all futures in the stream completed with failure as well as all futures completed with failure added to the stream in the future. Also, onError can be called multiple times using different callbacks.

# <a name="combinators">Combinators</a>

Combinators allow futures to be combined in ways that simplify application implementations. Futures that must be executed serially can be combined with flatmap. The map combinator is used to convert a future of one type to a future of another type. If a future is completed with failure the recoverWith combinator executes another future or the recover combinator executes a function that returns a value. Filters can be applied to previous completed futures using the withFilter combinator. The result of a successfully completed future can be processed with the foreach combinator and the andThen combinator can serialize processing completed future results. All combinators are supported for both Future&lt;T&gt; and FutureStream&lt;T&gt; and Future&lt;T&gt; and FutureStream&lt;T&gt; results can be combined using flatmap and recoverWith. The following sections will provide details for each combinator with code examples.

## <a name="map">map</a>

The map combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. The mapping function specified  is called only after successful completion of the Future&lt;T&gt; or FutureStream&lt;T&gt; and is of type T -> Try<M>. map for Future&lt;T&gt; instances returns a Future&lt;M&gt; and has the following definition,

```swift
// apply mapping using specified execution context
public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> Future<M>

// apply mapping using default execution context
public func map<M>(mapping:T -> Try<M>) -> Future<M> 
```

Notice that mapping returns a Try<T> so it can fail. If it does fail the Future&lt;M&gt; instance will be completed with failure otherwise it will be completed successfully.

```swift
```

map for FutureStream&lt;T&gt; instances returns a FutureStream&lt;M&gt; and has the following definition,

```swift
// apply mapping using specified execution context
public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> FutureStream<M>

// apply mapping using default execution context
public func map<M>(mapping:T -> Try<M>) -> FutureStream<M>
```

```swift
```

## <a name="flatmap">flatmap</a>

```swift
// apply mapping using specified execution context
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> Future<M>

// apply mapping using default execution context
public func flatmap<M>(mapping:T -> Future<M>) -> Future<M>
```

```swift
// apply mapping using specified execution context
public func flatMap<M>(executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping using default execution context
public func flatmap<M>(mapping:T -> FutureStream<M>) -> FutureStream<M>
```

```swift
// apply mapping to FutureStream<M> with specified capacity and execution context
public func flatmap<M>(capacity:Int, executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to FutureStream<M> with infinite capacity and specified execution context
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to FutureStream<M> with specified capacity and default context
public func flatmap<M>(capacity:Int, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to FutureStream<M> with infinite capacity and default context
public func flatmap<M>(mapping:T -> FutureStream<M>) -> FutureStream<M>
```

```swift
// apply mapping to Future<M> using specified execution context
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> FutureStream<M>

// apply mapping to Future<M> using default execution context
public func flatmap<M>(mapping:T -> Future<M>) -> FutureStream<M>
```

## <a name="recover">recover</a>

```swift
public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> Future<T>

public func recover(recovery: NSError -> Try<T>) -> Future<T>
```

```swift
public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> FutureStream<T>

public func recover(recovery:NSError -> Try<T>) -> FutureStream<T>
```

## <a name="recoverwith">recoverWith</a>

```swift
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> Future<T>

public func recoverWith(recovery:NSError -> Future<T>) -> Future<T>
```

```swift
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> FutureStream<T>

public func recoverWith(recovery:NSError -> Future<T>) -> FutureStream<T>
```

```swift
public func recoverWith(capacity:Int, executionContext:ExecutionContext, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

public func recoverWith(capacity:Int, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

public func recoverWith(recovery:NSError -> FutureStream<T>) -> FutureStream<T>
```

```swift
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> FutureStream<T>

public func recoverWith(recovery:NSError -> Future<T>) -> FutureStream<T>
```

## <a name="withfilter">withFilter</a>

## <a name="foreach">foreach</a>

## <a name="andthen">andThen</a>
