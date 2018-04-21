//
//  RSStandardNotification.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSStandardNotification: RSNotification {
    
    public let title: String
    public let body: String
    
    public let initialFire: JSON?
    public let repeating: JSON?
    public let monitoredValues: [JSON]
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let body: String = "body" <~~ json else {
                return nil
        }
        
        self.title = title
        self.body = body
        self.initialFire = "initialFire" <~~ json
        self.repeating = "repeat" <~~ json
        self.monitoredValues = "monitoredValues" <~~ json ?? []
        super.init(json: json)
    }
    
}
