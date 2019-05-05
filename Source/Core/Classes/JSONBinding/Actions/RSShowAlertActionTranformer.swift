//
//  RSShowAlertActionTranformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift
import ResearchSuiteExtensions

//This is pretty hacky. We should probably use the state for this
open class RSShowAlertActionTranformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "showAlertAction" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let alert = RSAlert(json: jsonObject),
            let layoutVC = context["layoutViewController"] as? UIViewController else {
            return nil
        }

        return { state, store in
            let alertVC = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
            alert.choices.forEach { choice in
                let alertAction = UIAlertAction(title: choice.title, style: choice.style, handler: { _ in
                    choice.onTapActions.forEach { store.processAction(action: $0, context: ["layoutViewController":layoutVC], store: store) }
                })
                alertVC.addAction(alertAction)
            }
            layoutVC.present(alertVC, animated: true, completion: nil)
            return nil
        }
    }
    
}
