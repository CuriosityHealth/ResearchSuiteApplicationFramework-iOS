//
//  RSStepTreeNodeGeneratorService.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
    
    func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        return self.nodeGenerators
            .compactMap { generator in
                if generator.supportsType(type: type) {
                    
                    return generator.generateNode(jsonObject: jsonObject, stepTreeBuilder: stepTreeBuilder, identifierPrefix: identifierPrefix, parent: parent)
                }
                else {
                    return nil
                }
            }
            .first
    }
    
}
