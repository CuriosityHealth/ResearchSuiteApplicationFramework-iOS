//
//  RSDatapointHeaderValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 8/23/18.
//

import UIKit
import LS2SDK
import Gloss

open class RSDatapointHeaderValueDescriptor: JSONDecodable {
    
    let schemaJSON: JSON
    let metadataJSON: JSON?
    let extraContext: JSON?
    
    public required init?(json: JSON) {
        
        guard let schema: JSON = "schema" <~~ json else {
                return nil
        }
        
        self.schemaJSON = schema
        self.metadataJSON = "metadata" <~~ json
        self.extraContext = "extraContext" <~~ json
    }
    
}

class RSDatapointHeaderValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "datapointHeader"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let descriptor = RSDatapointHeaderValueDescriptor(json: jsonObject) else {
            return nil
        }
        
        let fullContext: [String: AnyObject] = {
            if let extraContextJSON = descriptor.extraContext,
                let extraContext: [String: Any] = RSValueManager.processValue(jsonObject: extraContextJSON, state: state, context: context)?.evaluate() as? [String: Any] {
                return context.merging(extraContext as [String: AnyObject], uniquingKeysWith: { (obj1, obj2) -> AnyObject in
                    return obj2
                })
            }
            else {
                return context
            }
        }()
        
        guard let schemaJSON = RSValueManager.processValue(jsonObject: descriptor.schemaJSON, state: state, context: fullContext)?.evaluate() as? JSON,
            let schema = LS2Schema(json: schemaJSON) else {
                return nil
        }
        
        let metadata = descriptor.metadataJSON != nil ? (RSValueManager.processValue(jsonObject: descriptor.metadataJSON!, state: state, context: fullContext)?.evaluate() as? JSON) : nil
        
        let sourceName = LS2AcquisitionProvenance.defaultAcquisitionSourceName
        let creationDate = Date()
        let acquisitionSource = LS2AcquisitionProvenance(sourceName: sourceName, sourceCreationDateTime: creationDate, modality: .SelfReported)
        
        let header = LS2DatapointHeader(id: UUID(), schemaID: schema, acquisitionProvenance: acquisitionSource, metadata: metadata)
        
        return RSValueConvertible(value: header.toJSON() as AnyObject)
    }

}
