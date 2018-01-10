//
//  RSTappableListItem.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import Gloss

open class RSTappableListItem: RSListItem {
    
    public let onTapActions: [JSON]
    
    required public init?(json: JSON) {
        self.onTapActions = "onTap" <~~ json ?? []
        super.init(json: json)
    }

}
