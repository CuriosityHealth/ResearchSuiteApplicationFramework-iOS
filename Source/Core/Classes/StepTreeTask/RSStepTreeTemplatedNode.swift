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
    var children: [RSStepTreeNode]
    
    public init(identifier: String, identifierPrefix: String, type: String, template: Template, parameters: JSON?, parent: RSStepTreeNode?, stepTreeBuilder: RSStepTreeBuilder) {
        self.template = template
        self.parameters = parameters
        self.stepTreeBuilder = stepTreeBuilder
        self.children = []
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, children: [], parent: parent, navigationRules: nil, resultTransforms: nil)
    }
    
    open func generateParameters(result: ORKTaskResult, state: RSState) -> JSON? {
        
        guard let parameters: JSON = self.parameters else {
            return nil
        }
        
        var generatedParameters: JSON = [:]
        
        let context: [String: AnyObject] = ["taskResult": result, "node": self.parent as AnyObject]
        
        parameters.keys.forEach { (key) in
            
            guard let parameterJSON = parameters[key] as? JSON,
                let parameterValueConvertible = RSValueManager.processValue(jsonObject: parameterJSON, state: state, context: context) else {
                    return
            }
            
            generatedParameters[key] = parameterValueConvertible.evaluate()
        }
        
        return generatedParameters
    }
    
    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        
        //map data - I don't know how to do this just yet
        let parameters = self.generateParameters(result: result, state: state)
        
        //render template
        
        guard let renderedTemplate: String = (try? self.template.render(parameters)) else {
            return nil
        }
        
        //convert to json
        guard let jsonData = renderedTemplate.data(using: .utf8),
            let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON else {
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
