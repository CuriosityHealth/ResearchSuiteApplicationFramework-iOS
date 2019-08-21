//
//  RSDefaultStepResultGeneratorServices.swift
//  Pods
//
//  Created by James Kizer on 8/5/19.
//

import Foundation
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

public class RSTextFieldDefaultStepResultGenerator : RSDefaultStepResultGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "textfield"
    }
    
    public static func generate(type: String, stepIdentifier: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStepResult? {
        guard let descriptor = RSDefaultStepResultDescriptor(json: jsonObject),
            let text = helper.stateHelper?.objectInState(forKey: descriptor.defaultResultKey) as? String else {
            return nil
        }
        
        let textResult = ORKTextQuestionResult(identifier: descriptor.identifier)
        textResult.textAnswer = text

        return ORKStepResult(stepIdentifier: stepIdentifier, results: [textResult])
    }
    
    
}
