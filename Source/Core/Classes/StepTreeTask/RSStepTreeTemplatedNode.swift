//
//  RSStepTreeTemplatedNode.swift
//  Pods
//
//  Created by James Kizer on 4/22/18.
//

import UIKit
import Mustache
import ResearchKit
import Gloss

open class RSStepTreeTemplatedNode: RSStepTreeBranchNode {
    
    let template: Template
    let parameters: JSON?
    let stepTreeBuilder: RSStepTreeBuilder
//    var children: [RSStepTreeNode]
    
    public init(identifier: String, identifierPrefix: String, type: String, template: Template, parameters: JSON?, parent: RSStepTreeNode?, stepTreeBuilder: RSStepTreeBuilder) {
        self.template = template
        self.parameters = parameters
        self.stepTreeBuilder = stepTreeBuilder
//        self.children = []
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, children: [], parent: parent, navigationRules: nil, resultTransforms: nil, valueMapping: nil)
    }
    
    open func generateParameters(result: ORKTaskResult, state: RSState) -> JSON? {
        
        guard let parameters: JSON = self.parameters else {
            return nil
        }
        
        var generatedParameters: JSON = [:]
        
        let context: [String: AnyObject] = {
            if let stateHelper = self.stepTreeBuilder.rstb.helper.stateHelper as? RSTaskBuilderStateHelper {
                return stateHelper.extraStateValues.merging(["taskResult": result, "node": self.parent as AnyObject], uniquingKeysWith: { (obj1, obj2) -> AnyObject in
                    return obj2
                })
            }
            else {
                return ["taskResult": result, "node": self.parent as AnyObject]
            }
        }()
        
        parameters.keys.forEach { (key) in
            
            guard let parameterJSON = parameters[key] as? JSON,
                let parameterValueConvertible = RSValueManager.processValue(jsonObject: parameterJSON, state: state, context: context) else {
                    return
            }
            
            let parameter: AnyObject? = {
                if let parameterValue = parameterValueConvertible.evaluate() as? String {
                    
                    //try to localize string...
                    let localizedParameterValue = self.stepTreeBuilder.rstb.helper.localizationHelper.localizedString(parameterValue)
                    
                    return localizedParameterValue.replacingOccurrences(of: "\t", with: "") as AnyObject
                }
                else {
                    return parameterValueConvertible.evaluate()
                }
            }()
            
            generatedParameters[key] = parameter
        }
        
        return generatedParameters
    }
    
    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        
        //map data - I don't know how to do this just yet
        let parameters = self.generateParameters(result: result, state: state)
        
        //render template
        
        let renderedTemplateOpt: String? = {
            do {
                let render = try self.template.render(parameters)
                return render
            }
            catch _ {
                return nil
            }
            
        }()
        
        guard let renderedTemplate = renderedTemplateOpt else {
            return nil
        }
        
//        print(renderedTemplate)
        //convert to json
        guard let jsonData = renderedTemplate.data(using: .utf8),
            let json = (try! JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON else {
            return nil
        }
        
        //generate nodes
        guard let child = self.stepTreeBuilder.node(json: json, identifierPrefix: "\(self.identifierPrefix).\(self.identifier)", parent: self) else {
            return nil
        }
        
        //set children
        self.setChildren(children: [child])
        
        //call super
        return super.firstLeaf(with: result, state: state)
    }

}
