![SimpleFutures: Scala Futures for Swift](https://cdn.rawgit.com/troystribling/SimpleFutures/67f65a62ac294a6e1068387c7d1ebaabf4883b49/Assets/banner.png)

A Swift implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) with a few extras.

# <a name="motivation">Motivation</a>

Futures provide the construction of code that processes asynchronous requests by default in a non-blocking and concise manner. They support combinator interfaces for serializing the processing of requests, error recovery and filtering. In most Apple libraries asynchronous interfaces are supported through the delegate-protocol pattern or in some cases with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. It will be seen that Futures very nicely solve this problem. 

SimpleFutures is an implementation of [Scala Futures](http://docs.scala-lang.org/overviews/core/futures.html) in Swift and was influenced by [BrightFutures](https://github.com/Thomvis/BrightFutures).

# <a name="requirements">Requirements</a>

- iOS 8.0+
- Xcode 7.0+

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
``` 

If Future&lt;T&gt; is completed prior to calling onSuccess the callback will be called immediately, otherwise the it will be called when the future is later completed. Also, onSuccess can be called multiple times using different callbacks.

An application using a FutureStream&lt;T&gt; has a similar implementation, using the same [example](#completing_creating), but the behavior will be different. 

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onSuccess {result in
	…
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
``` 

If Future&lt;T&gt; is completed prior to calling onError the callback will be called immediately, otherwise the it will be called when the future is later completed. Also, onError can be called multiple times using different callbacks.

An application using a FutureStream&lt;T&gt; has a similar implementation, using the same [example](#completing_creating), but the behavior is different. 

```swift
let dataRequest = RequestData()
let dataFuture = dataRequest.request()
dataFuture.onFailure {error in
	…
}
``` 

Recall that a FutureStream&lt;T&gt; is a container of completed Future&lt;T&gt;s. When onFailure is called the specified callback will be executed for all futures in the stream completed with failure as well as all futures completed with failure added to the stream in the future. Also, onError can be called multiple times using different callbacks.

# <a name="combinators">Combinators</a>

Combinators allow futures to be combined in ways that simplify application implementations. Futures that must be executed serially can be combined with flatmap. The map combinator is used to complete a future with some other result. If a future is completed with failure the recover combinator can complete a future successfully with another result and the recoverWith completes the future with another future. Filters can be applied to previous completed futures using the withFilter combinator. The result of a successfully completed future can be processed with the foreach combinator and the andThen combinator can serialize processing completed future results. All combinators are supported for both Future&lt;T&gt; and FutureStream&lt;T&gt; and Future&lt;T&gt; and FutureStream&lt;T&gt; results can be combined using flatmap and recoverWith. The following sections will provide details for each combinator with code examples.

## <a name="map">map</a>

The map combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a mapping function of type T -> Try&lt;M&gt; as argument and returns a new Future&lt;T&gt; or FutureStream&lt;T&gt; instance. The Future&lt;M&gt; or FutureStream&lt;M&gt; returned by the mapping may be used to complete the instance returned by map. The mapping function is called only after successful completion otherwise the returned instance is completed with failure. The mapping function can fail completing the returned Future&lt;M&gt; or FutureStream&lt;M&gt; instance with failure. 

Futute&lt;T&gt; map is defined by,

```swift
// apply mapping using specified execution context
public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> Future<M>

// apply mapping using default execution context
public func map<M>(mapping:T -> Try<M>) -> Future<M> 
```

```swift
// create a promise
let promise = Promise<Bool>()
let future = promise.future

// called when future is completed successfully
future.onSuccess {value in
}
   
// called send future is completed with failure     
future.onFailure {error in
}

// create a new future with map and call specified mapping
// function if future is completed successfully
let mapped = future.map {value -> Try<Int> in
	return Try(Int(1))        
}

// called if future and mapped future completed successfully
mapped.onSuccess {value in
}

// called if mapped or future is completed successfuly
mapped.onFailure {error in
}
     
// complete future successfully   
promise.success(true)
```

map for FutureStream&lt;T&gt; instances returns a FutureStream&lt;M&gt; and has the following definition,

```swift
// apply mapping using specified execution context
public func map<M>(executionContext:ExecutionContext, mapping:T -> Try<M>) -> FutureStream<M>

// apply mapping using default execution context
public func map<M>(mapping:T -> Try<M>) -> FutureStream<M>
```

```swift
let promise = StreamPromise<Bool>()
let stream = promise.future

stream.onSuccess {value in
}
stream.onFailure {error in
}
        
let mapped = stream.map {value -> Try<Int> in
}
mapped.onSuccess {value in
}
mapped.onFailure {error in
}

promise.success(true)
promise.success(false)
```

## <a name="flatmap">flatmap</a>

The flatmap combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a mapping function of type T -> Future&lt;M&gt; or T -> FutureStream&lt;M&gt; as argument returning a new Future&lt;M&gt; or FutureStream&lt;M&gt; instance possibly of a different type. The Future&lt;M&gt; or FutureStream&lt;M&gt; returned by the mapping may be used to complete the instance returned by flatmap. The mapping function is called only after successful completion otherwise the returned instance is completed with failure. The mapping function can fail completing the returned Future&lt;M&gt; or FutureStream&lt;M&gt; instance with failure.

flatmap is the most used combinator because it allows Future&lt;T&gt; or FutureStream&lt;T&gt; instances to be called serially using the mapping function. This can be seen by following the sequence of events just described. The flatmap mapping function is called only after successful completion of the instance on which flatmap was called and the returned instance is completed only after the the mapping function instance is completed. Notice, that error handling is provided at each point in the calling sequence. Only if all instances are successfully completed will the instance returned by flatmap be successfully completed. Any failure in the calling sequence will cause the instance returned by flatmap to be completed with failure. Also, any number of Future&lt;T&gt; or FutureStream&lt;T&gt; instances can be combined with flatmap and each instance will be called serially.

Future&lt;T&gt; flatmap is defined by,

```swift
// apply mapping to result using specified execution context
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> Future<M>

// apply mapping to result using default execution context
public func flatmap<M>(mapping:T -> Future<M>) -> Future<M>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
        
let mapped = future.flatmap {value -> Future<Int> in
            let promise = Promise<Int>()
            promise.success(1)
            return promise.future
}
mapped.onSuccess {value in
}
mapped.onFailure {error in
}
promise.success(true)
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
        
let mapped = future.flatmap {value -> FutureStream<Int> in
	let promise = StreamPromise<Int>()
  promise.success(1)
  promise.success(2)
  return promise.future
}
mapped.onSuccess {value in
}
mapped.onFailure {error in
}

promise.success(true)
```

FutureStream&lt;T&gt; flatmap is defined by,

```swift
// apply mapping to result using specified execution context
public func flatMap<M>(executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to result using default execution context
public func flatmap<M>(mapping:T -> FutureStream<M>) -> FutureStream<M>
```

Future&lt;T&gt; instances can be flatmapped to  FutureStream&lt;M&gt; instances using a mapping function of type T -> FutureStream&lt;M&gt;. The Furture&lt;T&gt; flatmap methods that support this are defined by,

```swift
// apply mapping to result using specified execution context and returned FutureStream<M> will have specified capacity.
public func flatmap<M>(capacity:Int, executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to result using specified execution context and returned FutureStream<M> will have infinite capacity
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> FutureStream<M>) -> FutureStream<M>

// apply mapping to result using default execution context and returned FutureStream<M> will have specified capacity.
public func flatmap<M>(capacity:Int, mapping:T -> FutureStream<M>) -> FutureStream<M> 

// apply mapping to result using default execution context and returned FutureStream<M> will have infinite capacity.
public func flatmap<M>(mapping:T -> FutureStream<M>) -> FutureStream<M>
```

FurtureStream&lt;T&gt; instances can be flatmapped  using a mapping function of type T -> Future&lt;M&gt; returning a FutureStream&lt;M&gt; instance. The FutureStream&lt;T&gt; that support this are defined by,

```swift
// apply mapping to Future<M> using specified execution context
public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> Future<M>) -> FutureStream<M>

// apply mapping to Future<M> using default execution context
public func flatmap<M>(mapping:T -> Future<M>) -> FutureStream<M>
```

```swift
let promise = StreamPromise<Bool>()
let stream = promise.future

stream.onSuccess {value in        
}
stream.onFailure {error in
}
let mapped = stream.flatmap {value -> FutureStream<Int> in
	let promise = StreamPromise<Int>()
  promise.success(1)
  promise.success(2)
	return promise.future
}
mapped.onSuccess {value in
}
mapped.onFailure {error in
}

promise.success(true)
promise.success(false)
```

```swift
let promise = StreamPromise<Bool>()
let stream = promise.future

stream.onSuccess {value in        
}
stream.onFailure {error in
}
let mapped = stream.flatmap {value -> Future<Int> in
	 let promise = Promise<Int>()
   promise.success(1)
   return promise.future
}
mapped.onSuccess {value in
}
mapped.onFailure {error in
}

promise.success(true)
promise.success(false)
```

## <a name="recover">recover</a>

The recover combinator is supported by both Future&lt;T&gt; and  FutureStream&lt;T&gt; instances. It takes a recovery function  of type NSError -> Try&lt;T&gt; as argument and returns a new Future&lt;T&gt; or FutureStream&lt;T&gt; instance of the same type. If completed with success recover returns an instance successfully completed with result but if completed with failure recover completes the returned instance with the result of the specified recovery function. The recovery function can fail completing the returned Future&lt;T&gt; or FutureStream&lt;T&gt; instance with failure.

Future&lt;T&gt; recovery is defined by,

```swift
// recover with specified recovery function using specified execution context
public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> Future<T>

// recover with specified recovery function using default execution context
public func recover(recovery: NSError -> Try<T>) -> Future<T>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

let recovered = future.recover {error -> Try<Bool> in
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(true)
```

FutureStream&lt;T&gt; recovery is defined by,

```swift
// recover with specified recovery function using specified execution context
public func recover(executionContext:ExecutionContext, recovery:NSError -> Try<T>) -> FutureStream<T>

// recover with specified recovery function using default execution context
public func recover(recovery:NSError -> Try<T>) -> FutureStream<T>
```

```swift
let promise = StreamPromise<Int>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
        
let recovered = future.recover {error -> Try<Int> in
  return Try(1)
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(1)
promise.success(2)
```

## <a name="recoverwith">recoverWith</a>

The recoverWith combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a recovery function of type NSError -> Future&lt;T&gt; or NSError -> FutureStream&lt;T&gt; as argument and returns new instance of type Future&lt;T&gt; or FutureStream&lt;T&gt;. If an instance completes with success recoverWith returns a new Future&lt;T&gt; or FutureStream&ltT&gt; instance completed with result but if completed with failure recoverWith completes the returned Future&lt;T&gt; or FutureStream&lt;T&gt; instance with the result of the recovery function. The recovery function can fail completing the returned Future&lt;T&gt; or FutureStream&lt;T&gt; instance with failure.

Future&lt;T&gt; recoverWith is defined by,

```swift
// recoverWith with specified recovery function using the specified execution context
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> Future<T>

// recoverWith with specified recovery function using the default execution context
public func recoverWith(recovery:NSError -> Future<T>) -> Future<T>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

let recovered = future.recoverWith {error -> Future<Bool> in
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(true)
```

FutureStream&lt;T&gt; recoverWith is defined by,

```swift
// recoverWith specified recovery function using the species execution context
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> FutureStream<T>

// recoverWith specified recovery function using the default execution context
public func recoverWith(recovery:NSError -> Future<T>) -> FutureStream<T>
```

```swift
let promise = StreamPromise<Int>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
        
let recovered = future.recoverWith {error -> FutureStream<Int> in
	let promise = StreamPromise<Int>()
	promise.success(1)
	promise.success(2)
  return promise.future
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(3)
promise.success(4)
```

Future&lt;T&gt; instances can recoverWith a new FutureStream&lt;T&gt; instance using a recovery function of type  NSError -> FutureStream&lt;T&gt;. The Future&lt;T&gt; recoverWith methods supporting this are defined by,
 
```swift
// recoverWith specified recovery function using the specified execution context returning a FutureStream<T> with the specified capacity
public func recoverWith(capacity:Int, executionContext:ExecutionContext, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

// recoverWith the specified recovery function using the specified execution context returning a FutureStream<T> with infinite capacity
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

// recoverWith the specified recovery function using the default execution context returning a FutureStream<T> with the specified capacity
public func recoverWith(capacity:Int, recovery:NSError -> FutureStream<T>) -> FutureStream<T>

// recoverWith with the specified recovery function using the default execution context returning a FutureStream<T> with infinite capacity
public func recoverWith(recovery:NSError -> FutureStream<T>) -> FutureStream<T>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

let recovered = future.recoverWith {error -> FutureStream<Bool> in
	let promise = StreamPromise<Bool>()
  promise.success(false)
  return promise.future
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(true)
```

FutureStream&lt;T&gt; instances can recoverWith a new FutureStream&lt;T&gt; instance using a recovery function of type NSError -> Future&lt;T&gt;. The FutureStream&lt;T&gt; methods supporting this are defined by,

```swift
// recoverWith a recovery function returning Future<T> using the specified execution context
public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> Future<T>) -> FutureStream<T>

// recoverWith a recovery function returning Future<T> using the default execution context
public func recoverWith(recovery:NSError -> Future<T>) -> FutureStream<T>
```

```swift
let promise = StreamPromise<Int>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
        
let recovered = future.recoverWith {error -> Future<Int> in
	let promise = Promise<Int>()
  promise.success(1)
  return promise.future
}
recovered.onSuccess {value in
}
recovered.onFailure {error in
}

promise.success(1)
promise.success(2)
```

## <a name="withfilter">withFilter</a>

The withFilter combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a filter function of type T -> Bool as argument and returns a new Future&lt;T&gt; and FutureStream&lt;T&gt; instance of the same type. If either completes with success the specified filter function is applied to result. If the filter function returns true the returned instance is completed with result. If the filter function returns false the returned instance is completed with failure using the error TryError.filterFailed. If the Future&lt;T&gt; or FutureStream&lt;T&gt; instances are completed with failure withFilter completed the returned instance with failure.

Future&lt;T&gt; withFilter is defined by,

```swift
// apply specified filter function using specified execution context
public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> Future<T>

// apply specified filter function using default execution context
public func withFilter(filter:T -> Bool) -> Future<T>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

let filter = future.withFilter {value in
  return value
}
filter.onSuccess {value in
}
filter.onFailure {error in
}
promise.success(true)
```

FutureStream&lt;T&gt; withFilter is defined by,

```swift
// apply the specified filter function using the specified execution context
public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> FutureStream<T>

// apply the specified filter function using default execution context
public func withFilter(filter:T -> Bool) -> FutureStream<T>
```

```swift
let promise = StreamPromise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

let filter = future.withFilter {value in
  return value
}
filter.onSuccess {value in
}
filter.onFailure {error in
}
promise.success(true)
```

## <a name="foreach">foreach</a>

The foreach combinator os supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a function of type T -> Void as argument and returns Void. If the Future&lt;T&gt; or FutureStream&lt;T&gt; instance completes successfully the specified function is applied to result and not applied if completed with failure. This behavior is the same as [onSuccess](#onsuccess).
 
Future&lt;T&gt; foreach is defined by,

```swift
// apply the specified function using the specified execution context
public func foreach(executionContext:ExecutionContext, apply:T -> Void)

// apply the specified function using default execution context
public func foreach(apply:T -> Void)
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

future.foreach {value in
}
promise.success(true)
```

FutureStream&lt;T&gt; is defined by,

```swift
// apply the specified function using the specified execution context
public func foreach(executionContext:ExecutionContext, apply:T -> Void)

// apply the specified function using default execution context
public func foreach(apply:T -> Void)
```

```swift
let promise = StreamPromise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}

future.foreach {value in
}
promise.success(true)
```

## <a name="andthen">andThen</a>

The andThen combinator is supported by both Future&lt;T&gt; and FutureStream&lt;T&gt; instances. It takes a function of type Try<T> -> Void as argument and returns a new Future&lt;T&gt; and FutureStream&lt;T&gt; instance of the same type. It applies the specified function if the calling instance completes with success or failure and completes the returned instance with the successful or failed result.

Future&lt;T&gt; andThen is defined by,

```swift
// apply the specified function using the specified execution context
public func andThen(executionContext:ExecutionContext, complete:Try<T> -> Void) -> Future<T>

// apply the specified function using default execution context
public func andThen(complete:Try<T> -> Void) -> Future<T>
```

```swift
let promise = Promise<Bool>()
let future = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
       
let andThen = future.andThen {result in
	switch result {
	case .Success(_):
  case .Failure(_):
  }
}
        
andThen.onSuccess {value in
}        
andThen.onFailure {error in
}
promise.success(true)
```

FutureStream&lt;T&gt; is defined by,

```swift
// apply the specified function using the specified execution context
public func andThen(executionContext:ExecutionContext, complete:Try<T> -> Void) -> FutureStream<T>

// apply the specified function using default execution context
public func andThen(complete:Try<T> -> Void) -> FutureStream<T>
```

```swift
let promise = StreamPromise<Bool>()
let stream = promise.future

future.onSuccess {value in
}
future.onFailure {error in
}
       
let andThen = future.andThen {result in
	switch result {
		case .Success(_):
	  case .Failure(_):
  }
}
        
andThen.onSuccess {value in
}        
andThen.onFailure {error in
}
promise.success(true)
promise.success(false)
```
