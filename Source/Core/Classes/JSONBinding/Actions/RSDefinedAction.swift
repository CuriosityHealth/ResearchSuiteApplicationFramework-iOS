//
//  RSDefinedAction.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/14/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSDefinedAction: Gloss.JSONDecodable, RSActionTransformer {

    open let identifier: String
    open let json: JSON
    public required init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
                return nil
        }
    
        self.identifier = identifier
        self.json = json
        
    }
    
    
    
    public static func supportsType(type: String) -> Bool {
        return type == "definedAction"
    }
    
    public static func generateAction(jsonObject: JSON, context: [String : AnyObject], actionManager: RSActionManager) -> ((RSState, Store<RSState>) -> Action?)? {
        
        //this should go into the state, pull out the action specified by the identifier
        guard let identifier: String = "identifier" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let definedAction = RSStateSelectors.getDefinedAction(state, for: identifier) else {
                return nil
            }
            
            actionManager.processAction(action: definedAction.json, context: context, store: store)
            return nil
        }
        
    }
    
    
    

}
