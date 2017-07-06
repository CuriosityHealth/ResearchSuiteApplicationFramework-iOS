//
//  PSSRaw.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss
import ResearchSuiteApplicationFramework

open class PSSRaw: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    public var valueConvertibleType: String {
        return "resultTransform"
    }
    
    static public let kType = "PSSRaw"
    
    private static let supportedTypes = [
        kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes.contains(type)
    }
    
    public static let reversedIDs = [
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
        
        var answerMap: [String: Int] = [:]
        
        results.forEach { answerMap[$0.0] = $0.1 }
        
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
        
        return PSSRaw(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            answerMap: answerMap,
            score: score
        )
        
    }
    
    
    
    let score: Int
    let answerMap: [String: Int]
    
    public init?(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        answerMap: [String: Int],
        score: Int
        ) {
        
        self.score = score
        self.answerMap = answerMap
        
        super.init(
            type: YADLFullModerateOrHardIdentifiers.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }

}
