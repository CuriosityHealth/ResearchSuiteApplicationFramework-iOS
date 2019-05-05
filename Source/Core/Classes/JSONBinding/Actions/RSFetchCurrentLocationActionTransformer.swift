//
//  RSFetchCurrentLocationActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss

open class RSFetchCurrentLocationActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "fetchCurrentLocation" == type
    }
    
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        return { state, store in
            
            guard let onCompletion: RSPromise = "onCompletion" <~~ jsonObject else {
                return nil
            }
            
            store.dispatch(RSActionCreators.fetchCurrentLocation(onCompletion: onCompletion))
            return nil
        }
    }
    
}
