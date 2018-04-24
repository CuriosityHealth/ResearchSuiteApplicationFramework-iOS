//
//  RSStepTreeLeafNode.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ResearchSuiteTaskBuilder
import ResearchKit

open class RSStepTreeLeafNode: RSStepTreeNode {
    
    let stepGenerator: (RSTBTaskBuilder, String) -> ORKStep?
    public init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        parent: RSStepTreeNode?,
        stepGenerator: @escaping (RSTBTaskBuilder, String) -> ORKStep?
        ) {
        self.stepGenerator = stepGenerator
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, parent: parent)
    }
    
    open func step(taskBuilder: RSTBTaskBuilder) -> ORKStep? {
        return self.stepGenerator(taskBuilder, self.identifierPrefix)
    }
    
    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        return self
    }
    
//    open override func leaves() -> [RSStepTreeLeafNode] {
//        return [self]
//    }
    
//    open override var description: String {
//        
//        return self.identifierPrefix == "" ? "\(self.identifier): \(self.type)" : "\n\t\(self.identifierPrefix).\(self.identifier): \(self.type)"
//        
//    }
    
    

}
