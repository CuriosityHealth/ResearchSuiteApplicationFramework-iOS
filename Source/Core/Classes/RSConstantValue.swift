//
//  RSConstantValue.swift
//  Pods
//
//  Created by James Kizer on 6/26/17.
//
//

import UIKit
import Gloss
import CoreLocation

public class RSConstantValue: NSObject, Gloss.Decodable, ValueConvertible {
    
    public let identifier: String
    public let type: String
    public let value: AnyObject?
    
    
    //TODO: Default does not work for boolean
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let value: AnyObject? = "value" <~~ json,
            (value is NSNull || RSStateValue.typeMatches(type: type, object: value)) else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.value = value
        
        super.init()
        
    }
    
    public func evaluate() -> AnyObject? {
        return self.value
    }
    
    public override var description: String {
        return "\(self.value)"
    }

}
