//
//  YADLFullModerateOrHardIdentifiers.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss
import ResearchSuiteApplicationFramework

open class YADLFullModerateOrHardIdentifiers: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    public var valueConvertibleType: String {
        return "resultTransform"
    }
    
    static public let kType = "YADLFullModerateOrHardIdentifiers"
    
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

        guard let acceptableAnswers = parameters["acceptableAnswers"] as? [String],
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
        
        //check to see if the answer is in the acceptable answers
        let filteredResults = results.filter { (pair) -> Bool in
            return acceptableAnswers.contains(pair.1)
        }
        
        //extract identifiers
        let filteredIdentifiers = filteredResults.map { $0.0 }
        
        return YADLFullModerateOrHardIdentifiers(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            filteredIdentifiers: filteredIdentifiers
        )
    }
    
    public let filteredIdentifiers: [String]
    
    public init?(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        filteredIdentifiers: [String]
        ) {
        
        self.filteredIdentifiers = filteredIdentifiers
        
        super.init(
            type: YADLFullModerateOrHardIdentifiers.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
}

extension YADLFullModerateOrHardIdentifiers {
    open override func evaluate() -> AnyObject? {
        return self.filteredIdentifiers as AnyObject
    }
}
