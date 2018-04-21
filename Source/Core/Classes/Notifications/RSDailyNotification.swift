//
//  RSDailyNotification.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSDailyNotification: RSNotification {
    
    public let title: String
    public let body: String
    
    public let time: JSON
    public let weekdays: JSON?
    public let monitoredValues: [JSON]
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let body: String = "body" <~~ json,
            let time: JSON = "time" <~~ json else {
                return nil
        }
        
        self.title = title
        self.body = body
        self.time = time
        self.weekdays = "weekdays" <~~ json
        self.monitoredValues = "monitoredValues" <~~ json ?? []
        super.init(json: json)
    }
    
}
