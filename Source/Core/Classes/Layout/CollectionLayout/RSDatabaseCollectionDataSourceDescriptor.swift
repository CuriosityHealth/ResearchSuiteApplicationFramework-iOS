//
//  RSDatabaseCollectionDataSourceDescriptor.swift
//  Pods
//
//  Created by James Kizer on 5/29/18.
//

import UIKit
import Gloss

public struct RSSortSettings: JSONDecodable {
    public let keyPath: String
    public let ascending: Bool
    
    public init?(json: JSON) {
        
        guard let keyPath: String = "keyPath" <~~ json,
            let ascending: Bool = "ascending" <~~ json else {
                return nil
        }
        
        self.keyPath = keyPath
        self.ascending = ascending
    }
    
    public init(keyPath: String, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
    
}

open class RSDatabaseCollectionDataSourceDescriptor: RSCollectionDataSourceDescriptor {
    
    open let dataSourceIdentifier: String
    open let predicate: RSPredicate
    open let sortSettings: RSSortSettings?
    
    required public init?(json: JSON) {
        guard let dataSourceIdentifier: String = "dataSourceIdentifier" <~~ json,
            let predicate: RSPredicate = "predicate" <~~ json else {
            return nil
        }
        
        self.dataSourceIdentifier = dataSourceIdentifier
        self.predicate = predicate
        self.sortSettings = "sort" <~~ json
        
        super.init(json: json)
    }
    
}
