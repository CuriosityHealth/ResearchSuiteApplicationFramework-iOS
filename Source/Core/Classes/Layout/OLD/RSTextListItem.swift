//
//  RSTextListItem.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSTextListItem: RSListItem {
    
    public let text: AnyObject?
    
    required public init?(json: JSON) {
        self.text = "text" <~~ json
        super.init(json: json)
    }
    
}
