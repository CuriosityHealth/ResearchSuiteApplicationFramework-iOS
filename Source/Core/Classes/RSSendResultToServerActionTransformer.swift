//
//  RSSendResultToServerActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/25/17.
//
//

import UIKit
import Gloss
import ReSwift
import ResearchSuiteResultsProcessor


open class RSSendResultToServerActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "sendResultToServer" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {

        guard let valueJSON: JSON = "value" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let value = RSValueManager.evaluate(jsonObject:valueJSON, state: state, context: context) as? RSRPIntermediateResult else {
                return nil
            }
            
            return RSSendResultToServerAction(intermediateResult: value)
            
        }
    }
    
}
