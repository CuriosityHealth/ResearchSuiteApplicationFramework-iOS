//
//  RSDatapointValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/20/18.
//

import UIKit
import Gloss
import LS2SDK

open class RSDatapointValueDescriptor: JSONDecodable {
    
    let headerJSON: JSON
    let bodyJSON: JSON
    let extraContext: JSON?
    
    public required init?(json: JSON) {
        
        guard let header: JSON = "header" <~~ json,
            let body: JSON = "body" <~~ json else {
                return nil
        }
        
        self.headerJSON = header
        self.bodyJSON = body
        self.extraContext = "extraContext" <~~ json
    }

}

open class RSDatapointValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "datapoint"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let descriptor = RSDatapointValueDescriptor(json: jsonObject) else {
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

        guard let headerJSON = RSValueManager.processValue(jsonObject: descriptor.headerJSON, state: state, context: fullContext)?.evaluate() as? JSON,
            let header = LS2DatapointHeader(json: headerJSON),
            let bodyJSON = RSValueManager.processValue(jsonObject: descriptor.bodyJSON, state: state, context: fullContext)?.evaluate() as? JSON else {
                return nil
        }

        let datapoint = LS2ConcreteDatapoint(header: header, body: bodyJSON)
        return RSValueConvertible(value: datapoint as AnyObject)
    }

}

extension LS2ConcreteDatapoint: RSDatapoint {
    
}
