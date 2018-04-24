//
//  RSJSONCollectionResultTransformer.swift
//  Pods
//
//  Created by James Kizer on 4/23/18.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss

//extension ORKResult: JSONEncodable {
//    @objc public func toJSON() -> JSON? {
//        return nil
//    }
//}
//
//extension ORKCollectionResult: JSONEncodable {
//    @objc override public func toJSON() -> JSON? {
//        return nil
//    }
//}

open class RSJSONCollectionResultTransformer: RSRPIntermediateResult, RSRPFrontEndTransformer  {
    
    open class func type() -> String {
        return "collection"
    }
    open class func supportedTypes() -> [String] {
        return [self.type()]
    }
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes().contains(type)
    }
    
    open class func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let stepResults = parameters["results"] as? [ORKStepResult] else {
                return nil
        }
        
        
        var resultJSON: [JSON] = []
        stepResults.forEach { (stepResult) in
            
            
            
            if let results = stepResult.results {
                
                if let first = stepResult.firstResult,
                    let resultValue = (first as? RSRPDefaultValueTransformer)?.defaultSerializedValue {
                    resultJSON = resultJSON + [[
                        "identifier": stepResult.identifier,
                        "value": resultValue
                    ]]
                }
                
//                var stepResultJSON: JSON = [:]
//                results.forEach({ (result) in
//                    if let resultValueTransformer = result as? RSRPDefaultValueTransformer,
//                        let resultValue = resultValueTransformer.defaultValue {
//                        stepResultJSON[result.identifier] = resultValue
//                    }
//                })
//                resultJSON[stepResult.identifier] = stepResultJSON
            }

        }
        
        return self.init(
            type: self.type(),
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            results: resultJSON
        )
    }
    
    let results: [JSON]
    
    required public init?(
        type: String,
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        results: [JSON]
        ) {
        
        self.results = results
        
        super.init(
            type: type,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
//    public func toJSON() -> JSON? {
//        return self.results
//    }
    
    @objc open override func evaluate() -> AnyObject? {
        return self.results as AnyObject
    }

}


