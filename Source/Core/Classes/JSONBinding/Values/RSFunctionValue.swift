//
//  RSFunctionValue.swift
//  Pods
//
//  Created by James Kizer on 6/28/17.
//
//

import UIKit
import Gloss
import CoreLocation

//TODO: We can probably inject the state into here to allow functions to be a more complex view of the
//State than simple selectors can be
//Although, this might technically just be a selector...
//these provide bindings when state is managed by another module (e.g., login managed by SDK)
public class RSFunctionValue: Gloss.JSONDecodable, ValueConvertible {
    
    public let identifier: String
    public let type: String
    public let function: (() -> AnyObject?)?
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.function = nil
    }
    
    private init(
        identifier: String,
        type: String,
        function: (() -> AnyObject?)?
        ) {
        self.identifier = identifier
        self.type = type
        self.function = function
    }
    
    public func with(function: (() -> AnyObject?)?) -> RSFunctionValue {
        return RSFunctionValue(identifier: self.identifier, type: self.type, function: function)
    }
    
    public func evaluate() -> AnyObject? {
        assert(self.function != nil, "Function \(self.identifier) is not registered")
        return self.function!()
    }

}
