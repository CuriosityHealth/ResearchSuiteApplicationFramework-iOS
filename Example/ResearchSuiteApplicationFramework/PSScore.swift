//
//  PSScore.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss
import ResearchSuiteApplicationFramework

open class PSScore: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    
    public var valueConvertibleType: String {
        return "resultTransform"
    }
    
    static public let kType = "PSSScore"
    
    private static let supportedTypes = [
        kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes.contains(type)
    }
    
    static let reversedIDs = [
        "pss4",
        "pss5",
        "pss7",
        "pss8"
    ]
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let stepResults = parameters["results"] as? [ORKStepResult] else {
                return nil
        }
        
        let results: [(String, Int)] = stepResults.flatMap { (stepResult) -> (String, Int)? in
            guard let scaleResult = stepResult.firstResult as? ORKScaleQuestionResult,
                let score = scaleResult.scaleAnswer?.intValue,
                let identifier = stepResult.identifier.components(separatedBy: ".").last else {
                    return nil
            }
            
            return (identifier, score)
        }
        
        let score = results.reduce(0) { (acc, pair) -> Int in
            let adjustedScore: Int = {
                if PSScore.reversedIDs.contains(pair.0) {
                    return 4 - pair.1
                }
                else {
                    return pair.1
                }
            }()
            return acc + adjustedScore
        }
        
        return PSScore(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            score: score
        )
        
    }
    
    

    let score: Int
    
    public init?(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        score: Int
        ) {
        
        self.score = score
        
        super.init(
            type: YADLFullModerateOrHardIdentifiers.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }

}

extension PSScore {
    open override func evaluate() -> AnyObject? {
        return self.score as NSNumber
    }
}
