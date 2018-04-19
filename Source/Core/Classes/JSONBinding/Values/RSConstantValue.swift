//
//  RSConstantValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/26/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Gloss
import CoreLocation

public class RSConstantValue: NSObject, Gloss.JSONDecodable, ValueConvertible {
    
    public let identifier: String
    public let type: String
    public let value: AnyObject?
    
    
    //TODO: Default does not work for boolean
    required public init?(json: JSON) {
        
//        guard let identifier: String = "identifier" <~~ json,
//            let type: String = "type" <~~ json,
//            let value: AnyObject? = "value" <~~ json,
//            (value is NSNull || RSStateValue.typeMatches(type: type, object: value)) else {
//                return nil
//        }
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let rawValue: AnyObject? = "value" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        
        //
        if rawValue is NSNull {
            self.value = rawValue
        }
        else {
            self.value = RSStateValue.defaultValue(type: type, value: rawValue)?.evaluate()
        }
        
        super.init()
        
    }
    
    public func evaluate() -> AnyObject? {
        return self.value
    }
    
    public override var description: String {
        return "\(self.value)"
    }

}
