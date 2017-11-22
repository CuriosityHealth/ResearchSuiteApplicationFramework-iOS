//
//  RSDefaultStepResultTransformer.swift
//  Pods
//
//  Created by James Kizer on 7/5/17.
//
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss

open class RSDefaultStepResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    open class func type() -> String {
        return "default"
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
        
        guard let stepResult = parameters["result"] as? ORKStepResult,
            let result = stepResult.firstResult else {
                return self.init(
                    type: self.type(),
                    uuid: UUID(),
                    taskIdentifier: taskIdentifier,
                    taskRunUUID: taskRunUUID,
                    result: nil
                )
        }
        
        return self.init(
            type: self.type(),
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            result: result
        )
    }
    
    let result: ORKResult?
    
    required public init?(
        type: String,
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        result: ORKResult?
        ) {
        
        self.result = result
        
        super.init(
            type: type,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
}
