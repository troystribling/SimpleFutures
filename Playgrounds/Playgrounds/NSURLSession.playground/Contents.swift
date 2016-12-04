//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import SimpleFutures

PlaygroundPage.current.needsIndefiniteExecution = true

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

let requestFuture = URLSession.get(with: URL(string: "http://troystribling.com")!)

requestFuture.onSuccess { (data, response) in
    guard let response = response, let data = data else {
        return
    }
    print(String(data: data, encoding: String.Encoding.utf8)!)
    print(response)
}

requestFuture.onFailure { error in
    print(error)
}