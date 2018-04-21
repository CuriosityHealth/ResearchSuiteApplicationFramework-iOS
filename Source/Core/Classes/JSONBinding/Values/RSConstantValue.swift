//
//  RSConstantValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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
