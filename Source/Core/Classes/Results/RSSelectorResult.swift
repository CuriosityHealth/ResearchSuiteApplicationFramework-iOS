//
//  RSSelectorResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/4/17.
//

import UIKit
import ResearchSuiteResultsProcessor

open class RSSelectorResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    private static let supportedTypes = [
        "selectorResult"
    ]
    
    static public let kSelectorStepResultKey = "result"
    
    public static func supportsType(type: String) -> Bool {
        return self.supportedTypes.contains(type)
    }
    
    public class func transform(taskIdentifier: String, taskRunUUID: UUID, parameters: [String : AnyObject]) -> RSRPIntermediateResult? {
        
        guard let resultDict = RSRPDefaultResultHelpers.extractResults(parameters: parameters, forSerialization: false),
            let result = resultDict[RSSelectorResult.kSelectorStepResultKey] else {
            return nil
        }
        
        let defaultResult = RSSelectorResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            result: result,
            parameters: parameters)
        
        defaultResult.startDate = RSRPDefaultResultHelpers.startDate(parameters: parameters)
        defaultResult.endDate = RSRPDefaultResultHelpers.endDate(parameters: parameters)
        
        return defaultResult
        
    }
    
    public let result: AnyObject
    public let parameters: [String : AnyObject]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        result: AnyObject,
        parameters: [String : AnyObject]
        ) {
        
        self.result = result
        self.parameters = parameters
        
        super.init(
            type: "RSSelectorResult",
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
        
    }
    
}

extension RSSelectorResult {
    
    open func recursivelyExtractValue(path: [AnyObject], collection: AnyObject) -> AnyObject? {
        
        guard let head = path.first else {
            return nil
        }
        
        let tail = Array(path.dropFirst())
        
        if let index = head as? Int,
            let array = collection as? NSArray {
            guard array.count > index else {
                return nil
            }
            
            let value = array[index] as AnyObject

            if tail.count > 0 {
                return self.recursivelyExtractValue(path: tail, collection: value)
            }
            else {
                return value
            }
            
        }
        else if let key = head as? String,
            let dict = collection as? NSDictionary {
            
            guard let anyValue = dict[key] else {
                return nil
            }
            
            let value = anyValue as AnyObject
            
            if tail.count > 0 {
                return self.recursivelyExtractValue(path: tail, collection: value)
            }
            else {
                return value
            }
        }
        
        return nil
    }
    
    @objc open override func evaluate() -> AnyObject? {
        if let index = self.parameters["index"] as? Int,
            let array = self.result as? NSArray {
            return array[index] as AnyObject
        }
        else if let key = self.parameters["key"] as? String,
            let dict = self.result as? NSDictionary {
            return dict[key] as AnyObject
        }
        else if let path = self.parameters["path"] as? [AnyObject] {
            return self.recursivelyExtractValue(path: path, collection: self.result)
        }
        
        else {
            return self.result
        }
    }
}
