//
//  RSInstructionActivityElementTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

public class RSInstructionActivityElementTransformer: RSActivityElementTransformer {
    public static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        return taskBuilder.steps(forElement: jsonObject as JsonElement)
    }
    public static func supportsType(type: String) -> Bool {
        return type == "instruction"
    }
}
