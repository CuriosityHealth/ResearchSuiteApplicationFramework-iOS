//
//  RSStepTreeNodeGeneratorService.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import Foundation
import ResearchKit
import Gloss
import ResearchSuiteTaskBuilder

open class RSStepTreeNodeGeneratorService: NSObject {
    
    let nodeGenerators: [RSStepTreeNodeGenerator.Type]
    
    public override convenience init() {
        let nodeGenerators: [RSStepTreeNodeGenerator.Type] = []
        self.init(nodeGenerators: nodeGenerators)
    }
    
    public init(nodeGenerators: [RSStepTreeNodeGenerator.Type]) {
        self.nodeGenerators = nodeGenerators
        super.init()
    }
    
    func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
        return self.nodeGenerators
            .flatMap { $0.generateNode(jsonObject: jsonObject, stepTreeBuilder: stepTreeBuilder, identifierPrefix: identifierPrefix) }
            .first
    }
    
}
