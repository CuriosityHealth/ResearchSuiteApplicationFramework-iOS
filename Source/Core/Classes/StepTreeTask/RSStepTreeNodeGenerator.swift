//
//  RSStepTreeNodeGenerator.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

public protocol RSStepTreeNodeGenerator {
    
    static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode?
    static func supportsType(type: String) -> Bool
    
}


