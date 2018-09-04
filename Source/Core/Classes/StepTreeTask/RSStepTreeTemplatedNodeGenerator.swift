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
        
        //this will take an array, path, and value
        //will find first element that where value at path matches key and returns it
        //helpful when we want to access a single element in an array by an identifier
        let selectElement = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let array = boxes[0].arrayValue,
                let selectPath = boxes[1].value as? String,
                let selectValue = boxes[2].value as? NSObject else {
                    return nil
            }
            
            let element = array.first(where: { (box) -> Bool in
                guard let selectedBoxValue = box.mustacheBox(forKey: selectPath).value as? NSObject else {
                    return false
                }
//                print(selectedBoxValue)
                return selectedBoxValue.isEqual(selectValue)
            })
            
            return element
        }
        
        let contains = VariadicFilter { (boxes: [MustacheBox]) in

            guard let array = boxes[0].arrayValue,
                let matchingValue = boxes[1].value else {
                    return false
            }
            
            let mappedValues: [AnyObject] = array.compactMap({ $0.value as AnyObject })
            
            return mappedValues.contains(where: { $0.isEqual(matchingValue) })
        }
        
        let jsonString = Filter { (dict: JSON?) -> Any? in
            guard let jsonValue = dict,
                JSONSerialization.isValidJSONObject(jsonValue),
                let jsonData = try? JSONSerialization.data(withJSONObject: jsonValue, options: [.prettyPrinted]),
                let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            
            return jsonString
        }
        
        let some = Filter { (box: MustacheBox) -> Any? in
            if box.isEmpty {
                return false
            }
            
            if let dictionary = box.dictionaryValue {
                return dictionary.count > 0
            }
            else if let array = box.arrayValue {
                return array.count > 0
            }
            else {
                return false
            }
        }
        
        let listOfStrings = Filter { (box: MustacheBox) -> Any? in
            
            guard let array = box.arrayValue else {
                return nil
            }
            
            let strings: [String] = array.compactMap({ $0.value as? String })
            switch strings.count {
            case 0:
                return ""
            case 1:
                return strings[0]
            case 2:
                return "\(strings[0]) and \(strings[1])"
            default:
                return strings.enumerated().reduce("", { (acc, pair) -> String in
                    
//                    if last, don't append
                    //if second to last, append ", and "
                    //else, append ", "
                    if pair.offset == strings.count - 1 {
                        return acc + pair.element
                    }
                    else if pair.offset == strings.count - 2 {
                        return acc + pair.element + ", and "
                    }
                    else {
                        return acc + pair.element + ", "
                    }
                    
                })
            }
            
        }
        
        template.register(mapSelect, forKey: "mapSelect")
        template.register(contains, forKey: "contains")
        template.register(selectElement, forKey: "select")
        template.register(jsonString, forKey: "jsonString")
        template.register(some, forKey: "some")
        template.register(StandardLibrary.each, forKey: "each")
        template.register(listOfStrings, forKey: "listOfStrings")
        
        
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
