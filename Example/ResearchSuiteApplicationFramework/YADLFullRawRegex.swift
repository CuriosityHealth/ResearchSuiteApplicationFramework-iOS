//
//  YADLFullRawRegex.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import sdlrkx
import ResearchSuiteResultsProcessor
import Gloss
import ResearchKit

public class YADLFullRawRegex: RSRPFrontEndTransformer {

    static public let kType = "YADLFullRaw"
    
    private static let supportedTypes = [
        kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes.contains(type)
    }
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        
        guard let schemaID = parameters["schemaID"] as? JSON,
            let stepResults = parameters["results"] as? [ORKStepResult] else {
            return nil
        }
        
        let results: [(String, String)] = stepResults.flatMap { (stepResult) -> (String, String)? in
            guard let choiceResult = stepResult.firstResult as? ORKChoiceQuestionResult,
                let answer = choiceResult.choiceAnswers?.first as? String,
                let identifier = stepResult.identifier.components(separatedBy: ".").last else {
                    return nil
            }
            
            return (identifier, answer)
        }
        
        var resultMap: [String: String] = [:]
        results.forEach { (pair) in
            resultMap[pair.0] = pair.1
        }
        
        return YADLFullRaw(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            schemaID: schemaID,
            resultMap: resultMap
        )
    }
    
}
