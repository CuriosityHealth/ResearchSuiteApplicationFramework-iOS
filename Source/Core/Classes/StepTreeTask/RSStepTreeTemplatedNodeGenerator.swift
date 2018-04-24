//
//  RSStepTreeTemplatedNodeGenerator.swift
//  Pods
//
//  Created by James Kizer on 4/22/18.
//

import UIKit
import Gloss
import Mustache

open class RSStepTreeTemplatedNodeGenerator: RSStepTreeNodeGenerator {
    public static func supportsType(type: String) -> Bool {
        return "templateFile" == type
    }
    
    
    //passing the template to the node should be ok, but how do we specify the mappings?
//    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
//
//        guard let templateFileURL:
//
//        return nil
//    }
    
//    filters
    
    
    
    static func loadTemplate(descriptor: RSStepTreeTemplatedNodeDescriptor, stepTreeBuilder: RSStepTreeBuilder) -> Template? {
        
        //first, try to load from URL (base + path)
        if let urlBase = stepTreeBuilder.rstb.helper.stateHelper?.valueInState(forKey: descriptor.templateURLBaseKey) as? String,
            let urlPath = descriptor.templateURLPath,
            let url = URL(string: urlBase + urlPath) {
            
            do {
                return try Template(URL: url)
            }
            catch let error {
                debugPrint(error)
                return nil
            }
            
            
        }
        else if let filename = descriptor.templateFilename {
            do {
                return try Template(path: filename)
            }
            catch let error {
                debugPrint(error)
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    open static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        guard let descriptor = RSStepTreeTemplatedNodeDescriptor(json: jsonObject),
            let template = self.loadTemplate(descriptor: descriptor, stepTreeBuilder: stepTreeBuilder) else {
                return nil
        }
        
        let mapSelect = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let array = boxes[0].arrayValue,
                let selectKey = boxes[1].value as? String else {
                return nil
            }
            
            let returnArray = array.compactMap { $0.mustacheBox(forKey: selectKey) }
            
            return returnArray
        }
        
        let contains = VariadicFilter { (boxes: [MustacheBox]) in

            guard let array = boxes[0].arrayValue,
                let matchingValue = boxes[1].value as? AnyObject else {
                    return false
            }
            
            let mappedValues: [AnyObject] = array.compactMap({ $0.value as? AnyObject })
            
            return mappedValues.contains(where: { $0.isEqual(matchingValue) })
        }
        
        template.register(mapSelect, forKey: "mapSelect")
        template.register(contains, forKey: "contains")
        
        
        let node = RSStepTreeTemplatedNode(
            identifier: descriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: descriptor.type,
            template: template,
            parameters: descriptor.parameters,
            parent: parent,
            stepTreeBuilder: stepTreeBuilder
        )
        
        return node

    }
    
//    open static func supportsType(type: String) -> Bool {
//        return "templateFile" == type
//    }

}
