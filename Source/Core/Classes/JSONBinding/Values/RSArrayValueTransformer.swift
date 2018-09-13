//
//  RSArrayValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

//public struct RSArrayValueOperation: Glossy {
//    //map
//    //compactMap
//    //filter
//    //reduce
//}

public protocol RSArrayOperationFunction: Glossy {
    static func generate(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> RSArrayOperationFunction?
    func performOperation(array: [AnyObject], state: RSState, context: [String: AnyObject]) -> [AnyObject]
}

//open func RSArrayOperationSelectMapFunction: RSArrayOperationFunction {
//
//}
//
open class RSArrayOperationMappingFunction: RSArrayOperationFunction {
    
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        
        let selector: (AnyObject) -> AnyObject? = { element in
            
            var mappedValues: [String: Any] = [:]
            
            self.mapping.forEach { (pair) in

                let path = pair.value
                
                let pathComponentStrings: [String] = path.split(separator: ".").map { String($0) } as [String]
                let pathComponents: [AnyObject] = pathComponentStrings.map { componentString in
                    
                    if let componentInt = Int(componentString) {
                        return componentInt as AnyObject
                    }
                    else {
                        return componentString as AnyObject
                    }
                }
                
                guard let value = RSSelectorResult.recursivelyExtractValue(path: pathComponents, collection: element) else {
                    return
                }
                
                mappedValues[pair.key] = value
            }
            
            return RSValueConvertible(value: mappedValues as AnyObject).evaluate()
        }
        
        //apply selector
        return array.compactMap( selector )
    }
    
    let type: String
    let mapping: [String: String]
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "mapping",
            let mapping: [String: String] = "mapping" <~~ json else {
                return nil
        }
        
        self.type = type
        self.mapping = mapping
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "mapping" ~~> self.mapping
            ])
    }
    
}

open class RSArrayOperationTransformValueFunction: RSArrayOperationFunction {
    
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        
        let transformFunction: (AnyObject) -> AnyObject? = { element in
            
            let extraContext: [String: AnyObject] = ["element": element]
            let fullContext = context.merging(extraContext, uniquingKeysWith: { (obj1, obj2) -> AnyObject in
                return obj2
            })
            
            return RSValueManager.processValue(jsonObject: self.transform, state: state, context: fullContext)?.evaluate()
        }
        
        //apply transform
        return array.compactMap( transformFunction )
    }
    
    let type: String
    let transform: JSON
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "transform",
            let transform: JSON = "transform" <~~ json else {
                return nil
        }
        
        self.type = type
        self.transform = transform
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "transform" ~~> self.transform
            ])
    }
}

open class RSArrayOperationSelectCompactMapFunction: RSArrayOperationFunction {
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        
        let pathComponentStrings: [String] = self.path.split(separator: ".").map { String($0) } as [String]
        let pathComponents: [AnyObject] = pathComponentStrings.map { componentString in
            
            if let componentInt = Int(componentString) {
                return componentInt as AnyObject
            }
            else {
                return componentString as AnyObject
            }
        }
        
        let selector: (AnyObject) -> AnyObject? = { element in
            return RSSelectorResult.recursivelyExtractValue(path: pathComponents, collection: element)
        }
        
        //apply selector
        return array.compactMap( selector )
    }
    
    let type: String
    let path: String
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "select",
            let path: String = "path" <~~ json else {
                return nil
        }
        
        self.type = type
        self.path = path
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "path" ~~> self.path
            ])
    }
    
}

open class RSArrayOperationPredicateFilterFunction: RSArrayOperationFunction {
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        //apply predicate
        return RSPredicateManager.apply(predicate: self.predicate, to: array, state: state, context: context)
    }
    
    let type: String
    let predicate: RSPredicate
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "predicateFilter",
            let predicate: RSPredicate = "predicate" <~~ json else {
                return nil
        }
        
        self.type = type
        self.predicate = predicate
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "predicate" ~~> self.predicate
            ])
    }
    
    
}

open class RSArrayOperationIndividualElementFilterFunction: RSArrayOperationFunction {
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        return array.filter({ (element) -> Bool in
            
            var updatedContext = context
            updatedContext["element"] = element
            
            return RSPredicateManager.evaluatePredicate(predicate: self.predicate, state: state, context: updatedContext)
        })
    }
    
    let type: String
    let predicate: RSPredicate
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "individualElementFilter",
            let predicate: RSPredicate = "predicate" <~~ json else {
                return nil
        }
        
        self.type = type
        self.predicate = predicate
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "predicate" ~~> self.predicate
            ])
    }
    
    
}

open class RSArrayOperationAddingFunction: RSArrayOperationFunction {
    public static func generate(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> RSArrayOperationFunction? {
        return self.init(json: jsonObject)
    }
    
    public func performOperation(array: [AnyObject], state: RSState, context: [String : AnyObject]) -> [AnyObject] {
        
        guard let element = RSValueManager.processValue(jsonObject: self.elementJSON, state: state, context: context)?.evaluate() else {
            return array
        }
        return array + [element]
        
    }
    
    let type: String
    let elementJSON: JSON
    
    public required init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            type == "adding",
            let elementJSON: JSON = "element" <~~ json else {
                return nil
        }
        
        self.type = type
        self.elementJSON = elementJSON
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "element" ~~> self.elementJSON
            ])
    }
    
    
}



open class RSArrayValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "array"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        
        let arrayOpt: [AnyObject]? = {
            
            if let entriesJSON: [JSON] = "entries" <~~ jsonObject {
                return entriesJSON.compactMap { RSValueManager.processValue(jsonObject: $0, state: state, context: context)?.evaluate() }
            }
            else if let entriesJSON: JSON = "entries" <~~ jsonObject {
                let entries = RSValueManager.processValue(jsonObject: entriesJSON, state: state, context: context)?.evaluate()
                if let array = entries as? [AnyObject] {
                    return array
                }
                else if let dict = entries as? [String: Any] {
                    return dict.map { ["key": $0.key, "value": $0.value] as AnyObject }
                }
                else {
                    return nil
                }
            }
                
            else {
                return nil
            }
            
        }()
        
        guard let array = arrayOpt else {
            return nil
        }

        let operationTemplates: [RSArrayOperationFunction.Type] = [
            RSArrayOperationPredicateFilterFunction.self,
            RSArrayOperationSelectCompactMapFunction.self,
            RSArrayOperationIndividualElementFilterFunction.self,
            RSArrayOperationMappingFunction.self,
            RSArrayOperationTransformValueFunction.self,
            RSArrayOperationAddingFunction.self
        ]
        
        //for every operation json value, try to instantiate it
        if let operationsJSON: [JSON] = "operations" <~~ jsonObject {
            
            let operations: [RSArrayOperationFunction] = operationsJSON.compactMap({ (json) -> RSArrayOperationFunction? in
                
                
                //for each json operation provided, try to instananite it with templates
                let operations: [RSArrayOperationFunction] = operationTemplates.compactMap({ (operationTemplate: RSArrayOperationFunction.Type) -> RSArrayOperationFunction? in
                    return operationTemplate.generate(jsonObject: json, state: state, context: context)
                })
                
                assert(operations.count == 1)
                
                return operations.first
            })
            
            
            //now that we have our operation function, perform them on the array
            //we can reduce over the array applying each function ot
            let finalArray = operations.reduce(array) { (acc, operationFunction) -> [AnyObject] in
                
                return operationFunction.performOperation(array: acc, state: state, context: context)
                
            }
            
            return RSValueConvertible(value: finalArray as NSArray)
            
        }
        else {
            return RSValueConvertible(value: array as NSArray)
        }
        
//        if let filterPredicate: RSPredicate = "filterPredicate" <~~ jsonObject {
//            let filteredArray = array.filter { element in
//                return RSPredicateManager.evaluatePredicate(predicate: filterPredicate, state: state, context: ["element": element])
//            }
//            return RSValueConvertible(value: filteredArray as NSArray)
//        }
//        else {
//            return RSValueConvertible(value: array as NSArray)
//        }
        
    }

}
