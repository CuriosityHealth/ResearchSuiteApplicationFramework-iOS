//
//  ValueConvertible.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

public protocol ValueConvertible {
//    var valueConvertibleType: String { get }
    func evaluate() -> AnyObject?
}

open class RSValueConvertible: ValueConvertible {
    let value: AnyObject?
    public init(value: AnyObject?) {
        self.value = value
    }
    
    open func evaluate() -> AnyObject? {
        return self.value
    }
}
