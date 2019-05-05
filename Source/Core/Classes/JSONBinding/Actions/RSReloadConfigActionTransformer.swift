//
//  RSReloadConfigActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/27/18.
//

import UIKit
import Gloss
import ReSwift

open class RSReloadConfigActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "reloadConfig" == type
    }

    
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {

        return { state, store in
            
            RSApplicationDelegate.appDelegate.reloadConfig()
            return nil
            
        }
    }
    
}
