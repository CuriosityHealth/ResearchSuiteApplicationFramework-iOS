//
//  RSNotificationHandler.swift
//  Breathe
//
//  Created by James Kizer on 11/21/17.
//  Copyright © 2017 Curiosity Health. All rights reserved.
//

import UIKit
import Gloss

open class RSNotificationHandler: Gloss.Decodable {
    
    public let identifier: String
    public let handlerActions: [JSON]
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
            return nil
        }
        
        self.identifier = identifier
        self.handlerActions = "actions" <~~ json ?? []
    }
    
}
