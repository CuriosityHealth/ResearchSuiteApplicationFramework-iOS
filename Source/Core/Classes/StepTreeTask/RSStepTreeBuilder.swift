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

open class RSStepTreeStateHelper: RSTBStateHelper {
    
    weak var baseStateHelper: RSTBStateHelper?
    let valueMapping: [String: JSON]
    let state: RSState
    let context: [String: AnyObject]
    
    public init(stateHelper: RSTBStateHelper?, valueMapping: [String: JSON], state: RSState, context: [String: AnyObject]) {
        self.baseStateHelper = stateHelper
        self.valueMapping = valueMapping
        self.state = state
        self.context = context
    }
    
    
//    let context: [String: AnyObject] = ["taskResult": result, "node": self.parent as AnyObject]
//    
//    parameters.keys.forEach { (key) in
//    
//    guard let parameterJSON = parameters[key] as? JSON,
//    let parameterValueConvertible = RSValueManager.processValue(jsonObject: parameterJSON, state: state, context: context) else {
//    return
//    }
//    
//    generatedParameters[key] = parameterValueConvertible.evaluate()
//    }
    
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        
        if let valueJSON = self.valueMapping[forKey],
            let value = RSValueManager.processValue(jsonObject: valueJSON, state: self.state, context: self.context)?.evaluate() as? NSSecureCoding {
            return value
        }
        
        return self.baseStateHelper?.valueInState(forKey: forKey)
        
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.baseStateHelper?.setValueInState(value: value, forKey: forKey)
    }
    
}

open class RSStepTreeTaskBuilderHelper: RSTBTaskBuilderHelper {
    
    let stepTreeStateHelper: RSStepTreeStateHelper
    
    init(taskBuilderHelper: RSTBTaskBuilderHelper, valueMapping: [String: JSON], state: RSState, context: [String: AnyObject]) {
        self.stepTreeStateHelper = RSStepTreeStateHelper(stateHelper: taskBuilderHelper.stateHelper, valueMapping: valueMapping, state: state, context: context)
        super.init(builder: taskBuilderHelper.builder!, stateHelper: self.stepTreeStateHelper)
    }
    
}

open class RSStepTreeTaskBuilder: RSTBTaskBuilder {
    
    
//    open func createSteps(forType type: String, withJsonObject jsonObject: JsonObject, identifierPrefix: String = "") -> [ORKStep]? {
//        return self.stepGeneratorService.generateSteps(type: type, jsonObject: jsonObject, helper: self.helper, identifierPrefix: identifierPrefix)
//    }
    
    open func createSteps(forType type: String, withJsonObject jsonObject: JsonObject, identifierPrefix: String, parent: RSStepTreeBranchNode, taskResult: ORKTaskResult?) -> [ORKStep]? {
        
        let state: RSState = RSApplicationDelegate.appDelegate.store.state
        var context: [String: AnyObject] = ["node": parent as AnyObject]
        context["taskResult"] = taskResult
        
        let helper = RSStepTreeTaskBuilderHelper(taskBuilderHelper: self.helper, valueMapping: parent.valueMapping, state: state, context: context)
        
        return self.stepGeneratorService.generateSteps(type: type, jsonObject: jsonObject, helper: helper, identifierPrefix: identifierPrefix)
    }
    
}
open class RSStepTreeBuilder: NSObject {
    
    public let nodeGeneratorService: RSStepTreeNodeGeneratorService
//    public let rstb: RSTBTaskBuilder
    public let rstb: RSStepTreeTaskBuilder

    
    public init(
        stateHelper:RSTBStateHelper?,
        nodeGeneratorServices: [RSStepTreeNodeGenerator.Type]?,
        elementGeneratorServices: [RSTBElementGenerator]?,
        stepGeneratorServices: [RSTBStepGenerator]?,
        answerFormatGeneratorServices: [RSTBAnswerFormatGenerator]?
    ) {
        
//        self.rstb = RSTBTaskBuilder(
//            stateHelper: stateHelper,
//            elementGeneratorServices: nil,
//            stepGeneratorServices: stepGeneratorServices,
//            answerFormatGeneratorServices: answerFormatGeneratorServices
//        )
        
        self.rstb = RSStepTreeTaskBuilder(
            stateHelper: stateHelper,
            elementGeneratorServices: nil,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices)
    
        
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
            let branchNode = parent as? RSStepTreeBranchNode,
            let steps = self.rstb.createSteps(forType: descriptor.type, withJsonObject: json as JsonObject, identifierPrefix: identifierPrefix, parent: branchNode, taskResult: nil),
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
                stepGenerator: { (rstb, identifierPrefix, branchNode, taskResult) -> ORKStep? in
                    
                    return rstb.createSteps(
                        forType: descriptor.type,
                        withJsonObject: json as JsonObject,
                        identifierPrefix: identifierPrefix,
                        parent: branchNode,
                        taskResult: taskResult)?.first
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
