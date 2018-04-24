//
//  RSStepTreeBuilder.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchKit

open class RSStepTreeBuilder: NSObject {
    
    public let nodeGeneratorService: RSStepTreeNodeGeneratorService
    public let rstb: RSTBTaskBuilder

    
    public init(
        stateHelper:RSTBStateHelper?,
        nodeGeneratorServices: [RSStepTreeNodeGenerator.Type]?,
        elementGeneratorServices: [RSTBElementGenerator]?,
        stepGeneratorServices: [RSTBStepGenerator]?,
        answerFormatGeneratorServices: [RSTBAnswerFormatGenerator]?
    ) {
        
        self.rstb = RSTBTaskBuilder(
            stateHelper: stateHelper,
            elementGeneratorServices: nil,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices
        )
    
        
        if let _services = nodeGeneratorServices {
            self.nodeGeneratorService = RSStepTreeNodeGeneratorService(nodeGenerators: _services)
        }
        else {
            self.nodeGeneratorService = RSStepTreeNodeGeneratorService()
        }
        
    }
    
    public func stepTree(json: JSON, identifierPrefix: String, state: RSState) -> RSStepTree? {
        
        guard let rootNode = self.node(json: json, identifierPrefix: "", parent: nil) else {
            return nil
        }
        
        return RSStepTree(identifier: rootNode.identifier, root: rootNode, taskBuilder: self.rstb, state: state)
    }
    
    public func stepTree(jsonFileName: String, state: RSState) -> RSStepTree? {
        
        guard let element = self.rstb.helper.getJson(forFilename: jsonFileName) as? JSON else {
            return nil
        }
        
        return self.stepTree(json: element, identifierPrefix: "identifier" <~~ element ?? "", state: state)
        
    }
    
    public func node(json: JSON, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        
        //first try node generator service
        if let node = self.nodeGeneratorService.generateNode(jsonObject: json, stepTreeBuilder: self, identifierPrefix: identifierPrefix, parent: parent) {
            return node
        }
        
        guard let descriptor = RSTBElementDescriptor(json: json),
            let steps = self.rstb.createSteps(forType: descriptor.type, withJsonObject: json as JsonObject, identifierPrefix: identifierPrefix),
            steps.count > 0 else {
                return nil
        }
        
        if steps.count == 1 {
            
//            let step = steps.first!
            
            let node = RSStepTreeLeafNode(
                identifier: descriptor.identifier,
                identifierPrefix: identifierPrefix,
                type: descriptor.type,
                parent: parent,
                stepGenerator: { (rstb, identifierPrefix) -> ORKStep? in
                    return rstb.createSteps(forType: descriptor.type, withJsonObject: json as JsonObject, identifierPrefix: identifierPrefix)?.first
            })
            
            return node
        }
        else {
            assertionFailure("We can't handle more than one step per leaf node now. Implement a node generator (RSStepTreeNodeGeneratorService)")
            return nil
//            let children = steps.map({ (step) -> RSStepTreeLeafNode in
//                return RSStepTreeLeafNode(
//                    identifier: step.identifier,
//                    identifierPrefix: "\(identifierPrefix).\(d.identifier)",
//                    type: descriptor.type,
//                    stepGenerator: { (rstb, identifierPrefix) -> ORKStep? in
//                        return step
//                })
//            })
//            
//            let node = RSStepTreeBranchNode(
//                identifier: descriptor.identifier,
//                identifierPrefix: identifierPrefix,
//                type: descriptor.type,
//                children: children,
//                navigationRules: nil,
//                resultTransforms: nil
//            )
//            
//            return node
        }
        
    }
    
}
