//
//  RSActionSwitchTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/21/17.
//

import UIKit
import Gloss
import ReSwift

open class RSActionSwitchCase: Gloss.Decodable {
    
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
    
    open static func supportsType(type: String) -> Bool {
        return "switch" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let casesJSON: [JSON] = "cases" <~~ jsonObject else {
            return nil
        }
        
        let cases: [RSActionSwitchCase] = casesJSON.flatMap { RSActionSwitchCase(json: $0) }
        
        return { state, store in
            
            if let switchCase = cases.first(where: { switchCase in
                if let predicate = switchCase.predicate {
                    return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: context)
                }
                else { return true }
            }) {
                RSActionManager.processAction(action: switchCase.action, context: context, store: store)
            }
            
            return nil
        }
    }
    
}
