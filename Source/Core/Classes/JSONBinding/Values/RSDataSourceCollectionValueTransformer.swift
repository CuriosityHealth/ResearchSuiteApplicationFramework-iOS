//
//  RSDataSourceCollectionValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/20/18.
//

import UIKit
import Gloss
import LS2SDK

open class RSDataSourceCollectionValueTransformer: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "dataSourceCollection"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let dataSourceJSON: JSON = "dataSourceCollection" <~~ jsonObject,
            let descriptor = RSCollectionDataSourceDescriptor(json: dataSourceJSON),
            let dataSourceCollection = RSApplicationDelegate.appDelegate.collectionDataSourceManager.generateCollectionDataSource(dataSourceDescriptor: descriptor, state: state, context: context),
            let datapoints: [RSCollectionDataSourceElement] = dataSourceCollection.toArray() else {
                return nil
        }

        
        let datapointsJSON: [JSON] = datapoints.compactMap { $0.toJSON() }
        
        return RSValueConvertible(value: datapointsJSON as AnyObject)
        
    }
    

}
