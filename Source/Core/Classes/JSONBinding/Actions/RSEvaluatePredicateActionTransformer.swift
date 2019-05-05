//
//  RSEvaluatePredicateActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSEvaluatePredicateActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "evaluatePredicate" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let predicate: RSPredicate = "evaluatePredicate" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            let predicateValue = RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
//            debugPrint(predicateValue)
            
            return nil
            
        }
    }
    
}
