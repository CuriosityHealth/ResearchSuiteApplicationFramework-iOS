//
//  RSEvaluatePredicateActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss
import ReSwift

open class RSEvaluatePredicateActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "evaluatePredicate" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let predicate: RSPredicate = "evaluatePredicate" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            let predicateValue = RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
//            debugPrint(predicateValue)
            
            return nil
            
        }
    }
    
}
