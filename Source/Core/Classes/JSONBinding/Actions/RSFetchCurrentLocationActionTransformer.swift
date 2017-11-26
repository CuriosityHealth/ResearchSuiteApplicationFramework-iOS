//
//  RSFetchCurrentLocationActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import ReSwift
import Gloss

open class RSFetchCurrentLocationActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "fetchCurrentLocation" == type
    }
    
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        return { state, store in
            store.dispatch(RSActionCreators.fetchCurrentLocation())
            return nil
        }
    }
    
}
