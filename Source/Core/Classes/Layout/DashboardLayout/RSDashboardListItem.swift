//
//  RSDashboardListItem.swift
//  Pods
//
//  Created by James Kizer on 6/5/18.
//

import UIKit
import Gloss

open class RSDashboardListItem: Gloss.JSONDecodable {
    
    public let identifier: String
    public let type: String
    public let predicate: RSPredicate?
    public let cellMapping: JSON
    public let onTapActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let cellMapping: JSON = "cellMapping" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.predicate = "predicate" <~~ json
        self.cellMapping = cellMapping
        self.onTapActions = "onTap" <~~ json ?? []
        self.element = json
    }
    
}
