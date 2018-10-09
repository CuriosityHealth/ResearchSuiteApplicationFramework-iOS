//
//  RSGetDatapointValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/20/18.
//

import UIKit
import Gloss

open class RSFetchDatapointValueTransformer: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "fetchDatapoint"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        
        guard let dataSourceIdentifier: String = "dataSourceIdentifier" <~~ jsonObject,
            let dataSource = RSStateSelectors.getDataSource(state, for: dataSourceIdentifier),
            let idJSON: JSON = "id" <~~ jsonObject,
            let idString: String = RSValueManager.processValue(jsonObject: idJSON, state: state, context: context)?.evaluate() as? String,
//            let id = UUID(uuidString: idString),
            let datapoint = dataSource.getDatapoint(identifier: idString) else {
            return nil
        }
        
        if let convertToJSON: Bool = "convertToJSON" <~~ jsonObject,
            convertToJSON {
            
            guard let json = datapoint.toJSON()  else {
                    return nil
            }
            
            return RSValueConvertible(value: json as AnyObject)
            
        }
        else {
            return RSValueConvertible(value: datapoint as AnyObject)
        }
    }
}
