//
//  RSObservableValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

public class RSObservableValue<T: Equatable>: NSObject {
    
    public typealias ObservationClosure = (T?) -> ()
    
    let _closure: ObservationClosure?
    var _value: T?
    
    public func get() -> T? {
        return _value
    }
    
    public func set(value: T?) {
        if value != _value {
            self._value = value
            self._closure?(value)
        }
    }
    
    public init(initialValue: T?, observationClosure: ObservationClosure?) {
        self._closure = observationClosure
        super.init()
        
        self._value = initialValue
        
    }

}
