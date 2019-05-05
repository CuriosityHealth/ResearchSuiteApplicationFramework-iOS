//
//  RSSendResultToServerActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift
import ResearchSuiteResultsProcessor


open class RSSendResultToServerActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "sendResultToServer" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {

        guard let valueJSON: JSON = "value" <~~ jsonObject,
            let backendIdentifier: String = "backendIdentifier" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let valueConvertible = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context),
                let intermediateResult = valueConvertible.evaluate() as? RSRPIntermediateResult else {
                return nil
            }
            
            return RSSendResultToServerAction(backendIdentifier: backendIdentifier, intermediateResult: intermediateResult)
            
        }
    }
    
}
