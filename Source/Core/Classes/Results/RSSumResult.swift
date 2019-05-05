//
//  RSSumResult.swift
//  Alamofire
//
//  Created by James Kizer on 4/26/19.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss

public protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Summable {}
extension Double: Summable {}

@objc open class RSSumResult: RSRPIntermediateResult, RSRPFrontEndTransformer, JSONEncodable {
    
    open class func type() -> String {
        return "integerSum"
    }
    open class func supportedTypes() -> [String] {
        return [self.type()]
    }
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes().contains(type)
    }
    
    open class func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let stepResults = parameters["results"] as? [ORKStepResult] else {
            return nil
        }
        
        let decimalResult: Bool = {
            if let decimalResult = parameters["decimal"] as? Bool {
                return decimalResult
            }
            else {
                return false
            }
        }()
        
        let numericValues: [(String, NSNumber)] = stepResults.compactMap { stepResult in
            guard let transformable = stepResult.firstResult as? RSRPDefaultValueTransformer,
                let resultValue: NSNumber = transformable.defaultValue as? NSNumber else {
                    assertionFailure("Cannot convert result to NSNumber")
                    return nil
            }
            return (stepResult.identifier, resultValue)
        }
        
        //TODO: add support for reversing values
        //need to add list of identifiers to reverse as well as the starting value to subtract from
        let sum = numericValues.reduce(0) { (acc, pair) -> Int in
            return acc + pair.1.intValue
        }

        return self.init(
            type: self.type(),
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            sum: NSNumber(value: sum)
        )
    }
    
    let sum: NSNumber
    
    required public init?(
        type: String,
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        sum: NSNumber
        ) {
        
        self.sum = sum
        
        super.init(
            type: type,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
    public func toJSON() -> JSON? {
        return nil
    }
    
    @objc open override func evaluate() -> AnyObject? {
        return self.sum
    }
    
}
