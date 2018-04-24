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
                return RSValueManager.processValue(jsonObject: entriesJSON, state: state, context: context)?.evaluate() as? [AnyObject]
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
            RSArrayOperationSelectCompactMapFunction.self
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
