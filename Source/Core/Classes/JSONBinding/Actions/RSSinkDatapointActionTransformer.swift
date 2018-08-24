//
//  RSSinkDatapointActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import Gloss
import ReSwift
import ResearchSuiteResultsProcessor

extension RSRPIntermediateResult: RSDatapoint {
    
}

open class RSSinkDatapointActionTransformer: RSActionTransformer {
    open static func supportsType(type: String) -> Bool {
        return "sinkDatapoint" == type || "sinkDatapoints" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        let dataSinkIdentifiersOpt: [String]? = {
            if let dataSinkIdentifiers: [String] = "dataSinkIdentifiers" <~~ jsonObject {
                return dataSinkIdentifiers
            }
            else if let dataSinkIdentifier: String = "dataSinkIdentifier" <~~ jsonObject {
                return [dataSinkIdentifier]
            }
            else {
                return nil
            }
        }()
        
        guard let valueJSON: JSON = "value" <~~ jsonObject,
            let dataSinkIdentifiers = dataSinkIdentifiersOpt else {
                return nil
        }
        
        return { state, store in
            
            guard let valueConvertible = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context) else {
                    return nil
            }
            
            if let datapoint = valueConvertible.evaluate() as? RSDatapoint {
                dataSinkIdentifiers.forEach({ (identifier) in
                    let action: Action = RSSinkDatapointAction(dataSinkIdentifier: identifier, datapoint: datapoint)
                    store.dispatch(action)
                })
            }
            else if let datapoints = valueConvertible.evaluate() as? [RSDatapoint] {
                datapoints.forEach { datapoint in
                    dataSinkIdentifiers.forEach({ (identifier) in
                        let action: Action = RSSinkDatapointAction(dataSinkIdentifier: identifier, datapoint: datapoint)
                        store.dispatch(action)
                    })
                }
            }
            
            return nil
        }
    }
}


