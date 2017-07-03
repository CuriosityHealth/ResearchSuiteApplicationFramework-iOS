//
//  RSLayout.swift
//  Pods
//
//  Created by James Kizer on 7/3/17.
//
//

import UIKit
import Gloss

open class RSLayout: Decodable {

    public let identifier: String
    public let type: String
    public let onLoadActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.onLoadActions = "onLoad" <~~ json ?? []
        self.element = json
    }
    
}
