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

public protocol RSDefaultStepResultGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(type: String, stepIdentifier: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStepResult?
}

public class RSDefaultStepResultDescriptor : RSTBElementDescriptor {
    public let defaultResultKey: String
    public required init?(json: JSON) {
        guard let defaultResultKey: String = "defaultResultKey" <~~ json else {
                return nil
        }
        self.defaultResultKey = defaultResultKey
        super.init(json: json)
    }
}

public class RSFormStepResultDescriptor : RSTBElementDescriptor {
    public let defaultResultMap: [String: String]
    public required init?(json: JSON) {
        guard let defaultResultMap: [String: String] = "defaultResultMap" <~~ json else {
                return nil
        }
        self.defaultResultMap = defaultResultMap
        super.init(json: json)
    }
}

open class RSStepTreeStateHelper: RSTBStateHelper {
    
    let baseStateHelper: RSTBStateHelper?
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
    
    public func objectInState(forKey: String) -> AnyObject? {
        if let valueJSON = self.valueMapping[forKey] {
            return RSValueManager.processValue(jsonObject: valueJSON, state: self.state, context: self.context)?.evaluate()
        }
        
        return self.baseStateHelper!.objectInState(forKey: forKey)
    }
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        
        if let valueJSON = self.valueMapping[forKey] {
            return RSValueManager.processValue(jsonObject: valueJSON, state: self.state, context: self.context)?.evaluate() as? NSSecureCoding
        }

        return self.baseStateHelper!.valueInState(forKey: forKey)
        
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.baseStateHelper!.setValueInState(value: value, forKey: forKey)
    }
    
}

open class RSStepTreeTaskBuilderHelper: RSTBTaskBuilderHelper {
    
    
    let stepTreeStateHelper: RSStepTreeStateHelper
    
    init(taskBuilderHelper: RSTBTaskBuilderHelper, valueMapping: [String: JSON], state: RSState, context: [String: AnyObject]) {
        self.stepTreeStateHelper = RSStepTreeStateHelper(stateHelper: taskBuilderHelper.stateHelper, valueMapping: valueMapping, state: state, context: context)
        super.init(builder: taskBuilderHelper.builder!, stateHelper: self.stepTreeStateHelper, localizationHelper: taskBuilderHelper.localizationHelper)
    }
    
}

open class RSStepTreeTaskBuilder: RSTBTaskBuilder {
    
    
//    open func createSteps(forType type: String, withJsonObject jsonObject: JsonObject, identifierPrefix: String = "") -> [ORKStep]? {
//        return self.stepGeneratorService.generateSteps(type: type, jsonObject: jsonObject, helper: self.helper, identifierPrefix: identifierPrefix)
//    }
    
    //if we don't hold a reference to stateHelper, it will go out of scope
    //before the task has completed execution. RSTBTaskBuilder holds
    //its state helper weakly
    private let stateHelper: RSTBStateHelper?
    private let defaultStepResultGeneratorServices: [RSDefaultStepResultGenerator.Type]?
    public init(stateHelper: RSTBStateHelper?,
                         localizationHelper: RSTBLocalizationHelper?,
                         elementGeneratorServices: [RSTBElementGenerator]?,
                         stepGeneratorServices: [RSTBStepGenerator]?,
                         answerFormatGeneratorServices: [RSTBAnswerFormatGenerator]?,
                         defaultStepResultGeneratorServices: [RSDefaultStepResultGenerator.Type]?,
                         taskGeneratorServices: [RSTBTaskGenerator.Type]? = nil,
                         consentDocumentGeneratorServices: [RSTBConsentDocumentGenerator.Type]? = nil,
                         consentSectionGeneratorServices: [RSTBConsentSectionGenerator.Type]? = nil,
                         consentSignatureGeneratorServices: [RSTBConsentSignatureGenerator.Type]? = nil) {
        
        self.stateHelper = stateHelper
        self.defaultStepResultGeneratorServices = defaultStepResultGeneratorServices
        
        super.init(
            stateHelper: stateHelper,
            localizationHelper: localizationHelper,
            elementGeneratorServices: elementGeneratorServices,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices,
            taskGeneratorServices: taskGeneratorServices,
            consentDocumentGeneratorServices: consentDocumentGeneratorServices,
            consentSectionGeneratorServices: consentSectionGeneratorServices,
            consentSignatureGeneratorServices: consentSignatureGeneratorServices
        )
        
    }
    open func createSteps(
        forType type: String,
        withJsonObject jsonObject: JsonObject,
        identifierPrefix: String,
        parent: RSStepTreeBranchNode,
        taskResult: ORKTaskResult?
        ) -> [ORKStep]? {
        
        guard let state: RSState = RSApplicationDelegate.appDelegate.store?.state else {
            return nil
        }
        
        var context: [String: AnyObject] = ["node": parent as AnyObject]
        context["taskResult"] = taskResult
        
        let helper = RSStepTreeTaskBuilderHelper(taskBuilderHelper: self.helper, valueMapping: parent.valueMapping, state: state, context: context)
        
        return self.stepGeneratorService.generateSteps(type: type, jsonObject: jsonObject, helper: helper, identifierPrefix: identifierPrefix)
    }
    
    open func generateDefaultStepResult(
        forType type: String,
        withJsonObject jsonObject: JsonObject,
        stepIdentifier: String,
        parent: RSStepTreeBranchNode,
        taskViewController: ORKTaskViewController?
        ) -> ORKStepResult? {
        
        guard let state: RSState = RSApplicationDelegate.appDelegate.store?.state else {
            return nil
        }
        
        var context: [String: AnyObject] = ["node": parent as AnyObject]
        context["taskViewController"] = taskViewController
        
        let helper = RSStepTreeTaskBuilderHelper(
            taskBuilderHelper: self.helper,
            valueMapping: parent.valueMapping,
            state: state,
            context: context
        )
        
        if type == "form" {
            guard let items: [JSON] = "items" <~~ jsonObject else {
                return nil
            }
            
            let results: [ORKResult] = items.compactMap { (json) -> ORKResult? in
                
                guard let descriptor = RSTBElementDescriptor(json: json) else {
                    return nil
                }
                
                let itemStepIdentifier = "\(stepIdentifier).\(descriptor.identifier)"
                
                let service = self.defaultStepResultGeneratorServices?.first(where: { $0.supportsType(type: descriptor.type) })
                
                let stepResult = service?.generate(
                    type: descriptor.type,
                    stepIdentifier: itemStepIdentifier,
                    jsonObject: json as JSON,
                    helper: helper
                )
                
                return stepResult?.firstResult
            }
            
            
            if results.count > 0 {                
                return ORKStepResult(
                    stepIdentifier: stepIdentifier,
                    results: results
                )
            }
            else {
                return nil
            }
            
            
        }
        else {
            let service = self.defaultStepResultGeneratorServices?.first(where: { $0.supportsType(type: type) })
            
            return service?.generate(
                type: type,
                stepIdentifier: stepIdentifier,
                jsonObject: jsonObject as JSON,
                helper: helper
            )
        }
    }
    
    open func defaultStepResultGenerator(forType type: String, withJsonObject jsonObject: JsonObject) -> ((String, ORKTaskViewController?) -> ORKStepResult?)? {
        return nil
    }
    
}
open class RSStepTreeBuilder: NSObject {
    
    public let nodeGeneratorService: RSStepTreeNodeGeneratorService
//    public let rstb: RSTBTaskBuilder
    public let rstb: RSStepTreeTaskBuilder

    
    public init(
        stateHelper:RSTBStateHelper?,
        localizationHelper: RSTBLocalizationHelper?,
        nodeGeneratorServices: [RSStepTreeNodeGenerator.Type]?,
        elementGeneratorServices: [RSTBElementGenerator]?,
        stepGeneratorServices: [RSTBStepGenerator]?,
        answerFormatGeneratorServices: [RSTBAnswerFormatGenerator]?,
        defaultStepResultGeneratorServices: [RSDefaultStepResultGenerator.Type]?
    ) {
        
        self.rstb = RSStepTreeTaskBuilder(
            stateHelper: stateHelper,
            localizationHelper: localizationHelper,
            elementGeneratorServices: nil,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices,
            defaultStepResultGeneratorServices: defaultStepResultGeneratorServices)
    
        
        if let _services = nodeGeneratorServices {
            self.nodeGeneratorService = RSStepTreeNodeGeneratorService(nodeGenerators: _services)
        }
        else {
            self.nodeGeneratorService = RSStepTreeNodeGeneratorService()
        }
        
    }
    
    deinit {
        
//        print("deiniting RSStepTreeBuilder")
        
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
            
//            let defaultStepResultGenerator = self.rstb.defaultStepResultGenerator(forType: descriptor.type, withJsonObject: json as JsonObject)
            
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
            },
                defaultStepResultGenerator: { (rstb, identifierPrefix, taskViewController) -> ORKStepResult? in
                    
                    let stepIdentifier = "\(identifierPrefix).\(descriptor.identifier)"
                    return rstb.generateDefaultStepResult(
                        forType: descriptor.type,
                        withJsonObject: json as JsonObject,
                        stepIdentifier: stepIdentifier,
                        parent: branchNode,
                        taskViewController: taskViewController
                    )
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
