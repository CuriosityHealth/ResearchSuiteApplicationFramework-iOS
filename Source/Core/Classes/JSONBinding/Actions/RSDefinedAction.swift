//
//  RSDefinedAction.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/14/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
