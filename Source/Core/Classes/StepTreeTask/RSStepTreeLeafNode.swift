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
    
    let stepGenerator: (RSStepTreeTaskBuilder, String, RSStepTreeBranchNode, ORKTaskResult?) -> ORKStep?
    let defaultStepResultGenerator: ((String, ORKTaskViewController?) -> ORKStepResult?)?
    public init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        parent: RSStepTreeNode?,
        stepGenerator: @escaping (RSStepTreeTaskBuilder, String, RSStepTreeBranchNode, ORKTaskResult?) -> ORKStep?,
        defaultStepResultGenerator: ((String, ORKTaskViewController?) -> ORKStepResult?)? = nil
        ) {
        self.stepGenerator = stepGenerator
        self.defaultStepResultGenerator = defaultStepResultGenerator
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, parent: parent)
    }
    
    open func step(taskBuilder: RSStepTreeTaskBuilder, taskResult: ORKTaskResult? = nil) -> ORKStep? {
        guard let branchNode = self.parent as? RSStepTreeBranchNode else {
            return nil
        }
        return self.stepGenerator(taskBuilder, self.identifierPrefix, branchNode, taskResult)
    }
    
    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        return self
    }
    
    open func defaultStepResult(taskViewController: ORKTaskViewController?) -> ORKStepResult? {
        return self.defaultStepResultGenerator?(self.identifierPrefix, taskViewController)
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
