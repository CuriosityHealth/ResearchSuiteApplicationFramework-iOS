//
//  RSStepTreeLeafNode.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import Gloss
import ResearchSuiteTaskBuilder
import ResearchKit

open class RSStepTreeLeafNode: RSStepTreeNode {
    
    let stepGenerator: (RSTBTaskBuilder, String) -> ORKStep?
    init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        stepGenerator: @escaping (RSTBTaskBuilder, String) -> ORKStep?
        ) {
        self.stepGenerator = stepGenerator
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type)
    }
    
    open func step(taskBuilder: RSTBTaskBuilder) -> ORKStep? {
        return self.stepGenerator(taskBuilder, self.identifierPrefix)
    }

}
