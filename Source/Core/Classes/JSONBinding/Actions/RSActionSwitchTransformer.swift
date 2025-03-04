//
//  RSActionSwitchTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSActionSwitchCase: Gloss.JSONDecodable {
    
    let predicate: RSPredicate?
    let action: JSON
    
    public required init?(json: JSON) {
        guard let action: JSON = "action" <~~ json else {
                return nil
        }
        
        self.predicate = "predicate" <~~ json
        self.action = action
    }
    
}

open class RSActionSwitchTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "switch" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let casesJSON: [JSON] = "cases" <~~ jsonObject else {
            return nil
        }
        
        let cases: [RSActionSwitchCase] = casesJSON.compactMap { RSActionSwitchCase(json: $0) }
        
        return { state, store in
            
            if let switchCase = cases.first(where: { switchCase in
                if let predicate = switchCase.predicate {
                    return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: context)
                }
                else {
                    return true
                }
            }) {
                actionManager.processAction(action: switchCase.action, context: context, store: store)
            }
            
            return nil
        }
    }
    
}
