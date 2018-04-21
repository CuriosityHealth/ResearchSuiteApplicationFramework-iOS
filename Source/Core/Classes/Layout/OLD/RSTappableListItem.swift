//
//  RSTappableListItem.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
