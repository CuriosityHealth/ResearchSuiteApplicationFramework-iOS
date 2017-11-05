//
//  RSSelectorResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/4/17.
//

import UIKit
import ResearchSuiteResultsProcessor

open class RSSelectorResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    private static let supportedTypes = [
        "selectorResult"
    ]
    
    public static func supportsType(type: String) -> Bool {
        return self.supportedTypes.contains(type)
    }
    
    public class func transform(taskIdentifier: String, taskRunUUID: UUID, parameters: [String : AnyObject]) -> RSRPIntermediateResult? {

        let keys = parameters.keys
        guard keys.count == 1,
            let key = keys.first else {
            return nil
        }
        
        guard let resultDict = RSRPDefaultResultHelpers.extractResults(parameters: parameters, forSerialization: false),
            let result = resultDict[key] else {
            return nil
        }
        
        let defaultResult = RSSelectorResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            result: result)
        
        defaultResult.startDate = RSRPDefaultResultHelpers.startDate(parameters: parameters)
        defaultResult.endDate = RSRPDefaultResultHelpers.endDate(parameters: parameters)
        
        return defaultResult
        
    }
    
    public let result: AnyObject
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        result: AnyObject
        ) {
        
        self.result = result
        
        super.init(
            type: "RSSelectorResult",
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
        
    }
    
}

extension RSSelectorResult {
    open override func evaluate() -> AnyObject? {
        return self.result
    }
}
