//
//  TestHelper.swift
//  SimpleFutures
//
//  Created by Troy Stribling on 12/20/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import SimpleFutures

public enum TestFailure: Int, Swift.Error {
    case error
    case recoveryError
}

struct TestContext {
    static let immediate = ImmediateContext()
}

