//
//  RSShowAlertActionTranformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
//

import UIKit
import Gloss
import ReSwift

open class RSAlertChoice: Gloss.JSONDecodable {
    
    public let title: String
    public let style: UIAlertActionStyle
    public let onTapActions: [JSON]
    
    private static func styleFor(_ styleString: String) -> UIAlertActionStyle? {
        switch styleString {
        case "default":
            return .default
        case "cancel":
            return .cancel
        case "destructive":
            return .destructive
        default:
            return nil
        }
    }
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let styleString: String = "style" <~~ json,
            let style = RSAlertChoice.styleFor(styleString) else {
                return nil
        }
        
        self.title = title
        self.style = style
        self.onTapActions =  "onTap" <~~ json ?? []
    }
    
}
open class RSAlert: Gloss.JSONDecodable {

    public let title: String
    public let text: String?
    public let choices: [RSAlertChoice]
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json else {
                return nil
        }
        
        self.title = title
        self.text = "text" <~~ json
        self.choices = "choices" <~~ json ?? []
    }
    
}


//This is pretty hacky. We should probably use the state for this
open class RSShowAlertActionTranformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "showAlertAction" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
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
