//
//  RSActivityElementTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

public protocol RSActivityElementTransformer {
    static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]?
    static func supportsType(type: String) -> Bool
}
