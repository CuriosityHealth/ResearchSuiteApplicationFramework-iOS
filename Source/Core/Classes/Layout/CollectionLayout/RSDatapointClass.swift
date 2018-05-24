//
//  RSDatapointClass.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import Gloss
import LS2SDK

open class RSDatapointClass: JSONDecodable, Hashable, Equatable {
    public var hashValue: Int {
        return identifier.hashValue
    }
    
    public static func == (lhs: RSDatapointClass, rhs: RSDatapointClass) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public let identifier: String
    public let order: Int
    public let predicate: RSPredicate?
    public let cellIdentifier: String
    public let cellMapping: [String: JSON]
    public let onTapActions: [JSON]
    public let dateSelector: ((LS2Datapoint) -> Date?)
    
    public required init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let cellIdentifier: String = "cellIdentifier" <~~ json,
            let cellMapping: [String: JSON] = "cellMapping" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.order = "order" <~~ json ?? 0
        self.predicate = "predicate" <~~ json
        self.cellIdentifier = cellIdentifier
        self.cellMapping = cellMapping
        self.onTapActions = "onTap" <~~ json ?? []
        
        if let dateSelectorPath: String = "dateSelectorPath" <~~ json {
            self.dateSelector = { datapoint in
                if let datapointJSON = datapoint.toJSON(),
                    let dateString: String = dateSelectorPath <~~ datapointJSON {
                    return ISO8601DateFormatter().date(from: dateString)
                }
                else {
                    return nil
                }
            }
        }
        else {
            self.dateSelector = { datapoint in
                return datapoint.header?.acquisitionProvenance.sourceCreationDateTime
            }
        }
        
    }
    
}
