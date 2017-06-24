//
//  YADLFullRaw+ValueConvertible.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import sdlrkx
import ResearchSuiteApplicationFramework

extension YADLFullRaw: ValueConvertible {
   
    public var valueConvertibleType: String {
        return "resultTransform"
    }
    
    public func evaluate() -> AnyObject? {
        return self
    }
}
