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
    public let filterPrompt: String
    public let order: Int
    public let dataSource: RSCollectionDataSourceDescriptor
    public let cellIdentifier: String
    public let cellTint: JSON?
    public let cellMapping: [String: JSON]
    public let onTapActions: [JSON]
    public let dateSelector: ((RSCollectionDataSourceElement) -> Date?)
    
    public required init?(json: JSON) {
        
//        debugPrint(json)
        
        guard let identifier: String = "identifier" <~~ json,
            let collectionDataSourceJSON: JSON = "collectionDataSource" <~~ json,
            let dataSource = RSCollectionDataSourceDescriptor(json: collectionDataSourceJSON),
            let cellIdentifier: String = "cellIdentifier" <~~ json,
            let cellMapping: [String: JSON] = "cellMapping" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.filterPrompt = "filterPrompt" <~~ json ?? identifier
        self.order = "order" <~~ json ?? 0
        self.dataSource = dataSource
        self.cellIdentifier = cellIdentifier
        self.cellTint = "cellTint" <~~ json
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
//                return datapoint.header?.acquisitionProvenance.sourceCreationDateTime
                return datapoint.primaryDate
            }
        }
        
    }
    
}
