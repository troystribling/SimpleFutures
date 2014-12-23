//
//  Optional.swift
//  Wrappers
//
//  Created by Troy Stribling on 12/21/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation

extension Optional {
    
    func flatmap<M>(mapping:T -> M?) -> M? {
        switch self {
        case .Some(let value):
            return mapping(value)
        case .None:
            return nil
        }
    }
    
    func getOrElse(value:T) -> T? {
        switch self {
        case .Some(let value):
            return value
        case .None:
            return value
        }
    }
    
    
}

public func map<T,M>(maybe:T?, mapping:T -> M) -> M? {
    return maybe.map(mapping)
}

public func flatmap<T,M>(maybe:T?, mapping:T -> M?) -> M? {
    return maybe.flatmap(mapping)
}

public func getOrElse<T>(maybe:T?, value:T) -> T? {
    return maybe.getOrElse(value)
}

