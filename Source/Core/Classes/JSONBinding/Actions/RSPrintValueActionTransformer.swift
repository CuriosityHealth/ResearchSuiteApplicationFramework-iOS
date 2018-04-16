//
//  RSPrintValueActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//

import UIKit
import Gloss
import ReSwift

open class RSPrintValueActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "printValue" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let valueJSON: JSON = "value" <~~ jsonObject else {
                return nil
        }
        
        return { state, store in
            
            guard let valueConvertible = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context) else {
                return nil
            }
            
            if let value = valueConvertible.evaluate() as? NSObject {
                print("the value is: \(value)")
            }
            else {
                print(valueConvertible.evaluate() as Any)
            }
            
            return nil
            
        }
    }
    
}
