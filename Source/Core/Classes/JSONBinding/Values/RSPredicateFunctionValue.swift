//
//  RSPredicateFunctionValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/14/18.
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

open class RSPredicateFunctionValue: RSFunctionValue {

    open let identifier: String
    open let predicate: RSPredicate
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let predicate: RSPredicate = "predicate" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.predicate = predicate
    }
    
    open func generateValueConvertible(state: RSState) -> ValueConvertible {
        let predicateValue = RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
        return RSValueConvertible(value: NSNumber(booleanLiteral: predicateValue))
    }
    

}
