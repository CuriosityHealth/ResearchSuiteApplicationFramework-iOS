//
//  RSStepTreeNodeGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

public protocol RSStepTreeNodeGenerator {
    
    static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode?
    static func supportsType(type: String) -> Bool
    
}


