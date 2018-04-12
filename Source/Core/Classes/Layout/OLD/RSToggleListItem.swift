//
//  RSToggleListItem.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import Gloss

open class RSToggleListItem: RSListItem {
    public let boundStateIdentifier: String
    
    required public init?(json: JSON) {
        
        guard let boundStateIdentifier: String = "boundStateIdentifier" <~~ json else {
            return nil
        }
        self.boundStateIdentifier = boundStateIdentifier
        super.init(json: json)
    }
    
}

