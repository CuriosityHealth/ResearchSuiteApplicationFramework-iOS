//
//  RSRequestPathChangeActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSRequestPathChangeActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "requestPathChange" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let valueJSON: JSON = "requestedPath" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let valueConvertible = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context) else {
                return nil
            }
            
            if let requestedPath = valueConvertible.evaluate() as? NSString {
                return RSActionCreators.requestPathChange(path: requestedPath.lowercased as String)(state, store)
            }
            else {
                return nil
            }

        }
    }
    
}
