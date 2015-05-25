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

# Model

A Future instance is a read-only encapsulation of an immutable result that can be computed anytime in the future. When the result is computed the Future is said to be completed. A Future may be completed successfully with a value or failed with an error.

## Execution Context

## Try

## Promise

## Future

## StreamPromise

## FutureStream

# Callbacks

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