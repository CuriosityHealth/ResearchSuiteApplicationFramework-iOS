//
//  RSFunctionValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/28/17.
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

//TODO: We can probably inject the state into here to allow functions to be a more complex view of the
//State than simple selectors can be
//Although, this might technically just be a selector...
//these provide bindings when state is managed by another module (e.g., login managed by SDK)

public protocol RSFunctionValue {
    var identifier: String { get }
    func generateValueConvertible(state: RSState) -> ValueConvertible
}

open class RSDefinedFunctionValue: Gloss.JSONDecodable, RSFunctionValue {
    
    open let identifier: String
    open let type: String
    open let function: ((RSState) -> AnyObject?)?
    
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
        function: ((RSState) -> AnyObject?)?
        ) {
        self.identifier = identifier
        self.type = type
        self.function = function
    }
    
    public func with(function: ((RSState) -> AnyObject?)?) -> RSFunctionValue {
        return RSDefinedFunctionValue(identifier: self.identifier, type: self.type, function: function)
    }
    
    open func generateValueConvertible(state: RSState) -> ValueConvertible {
        let result: AnyObject? = self.function!(state)
        return RSValueConvertible(value: result)
    }

}
