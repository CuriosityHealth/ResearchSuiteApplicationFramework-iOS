//
//  RSPredicateFunctionValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/14/18.
//

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
        let predicateValue = RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
        return RSValueConvertible(value: NSNumber(booleanLiteral: predicateValue))
    }
    

}
