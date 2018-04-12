//
//  RSStepTreeNavigationRule.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import Gloss

open class RSStepTreeNavigationRule: Gloss.JSONDecodable {
    let trigger: String
    let conditionalNavigation: [RSStepTreeConditionalNavigationRule]
    let destination: String
    
    public required init?(json: JSON) {
        
        guard let trigger: String = "trigger" <~~ json,
            let destination: String = "destination" <~~ json else {
                return nil
        }
        
        self.trigger = trigger
        self.destination = destination
        let conditionalNavJSON: [JSON]? = "conditionalNavigation" <~~ json
        self.conditionalNavigation = conditionalNavJSON?.compactMap { RSStepTreeConditionalNavigationRule(json: $0) } ?? []
        
    }
}
