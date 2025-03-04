//
//  RSPredicateManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/16/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public class RSPredicateLog: JSONEncodable {
    
    
    let predicate: RSPredicate
    let uuid: UUID
    let timestamp: Date
    var substitutions: [String: Any] = [:]
    var nsPredicate: NSPredicate?
    var status: String = "created"
    var evaluated: Bool?
//    var malformedAction = false
//    var predicateResult: Bool? = nil
//    var successfulTransforms: [String] = []
    
    public static func encode(substitutions: [String: Any]) -> JSON? {
        
        let substitutionsJSON: [JSON?] = substitutions.map { (pair) -> JSON? in
            return RSValueLog.encode(key: pair.key)(pair.value as AnyObject)
        }
        
        return jsonify(substitutionsJSON)
        
    }
    
    public func toJSON() -> JSON? {
        
        return jsonify([
            "predicate" ~~> self.predicate,
            "uuid" ~~> self.uuid,
            Gloss.Encoder.encode(dateISO8601ForKey: "timestamp")(self.timestamp),
            "substitutedValues" ~~> RSPredicateLog.encode(substitutions: self.substitutions),
            "status" ~~> self.status,
            "evaluated" ~~> self.evaluated
            ])
    }
    
    public init(predicate: RSPredicate) {
        self.predicate = predicate
        self.uuid = UUID()
        self.timestamp = Date()
    }
    
}

public protocol RSPredicateManagerDelegate: class {
    func log(log: RSPredicateLog)
}

open class RSPredicateManager: NSObject {

    public weak var delegate: RSPredicateManagerDelegate?
    
//    public func generatePredicateExpression(predicate: RSPredicate, state: RSState, context: [String: AnyObject], log: RSPredicateLog?) -> RSPredicateExpression? {
//
//        let predicateExpressionOpt: RSPredicateExpression? = {
//            do {
//                return try RSPredicateExpression.generateExpression(format: predicate.format)
//            }
//            catch let e {
//                print(e)
//                assertionFailure(e.localizedDescription)
//                return nil
//            }
//        }()
//
//        guard let predicateExpression = predicateExpressionOpt else {
//            return nil
//        }
//
//        guard let substitutionsJSON = predicate.substitutions else {
//                return predicateExpression
//        }
//
//        var substitutions: [String: NSObject] = [:]
//
//        substitutionsJSON.forEach({ (key: String, value: JSON) in
//
//            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
//
//                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
//                //we also want to potentially have a null value substituted
//                if let value = valueConvertible.evaluate() as? NSObject {
//                    substitutions[key] = value
//                }
//                else {
//                    //                    assertionFailure("Added NSNull support for this type")
////                    let nilObject: AnyObject? = nil as AnyObject?
//                    substitutions[key] = NSNull()
//                }
//
//            }
//
//        })
//
//        guard substitutions.count == substitutionsJSON.count else {
//            return nil
//        }
//
//        let predicateWithSubstitutions = predicateExpression.withSubstitutions(substitutions: substitutions)
//        return predicateWithSubstitutions
//
//    }
    
    public func generatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject], log: RSPredicateLog?) -> NSPredicate? {
        
        let nsPredicate = NSPredicate.init(format: predicate.format)
        
        log?.status = "Generated Predicate"
        
        guard let substitutionsJSON = predicate.substitutions else {
            log?.nsPredicate = nsPredicate
            return nsPredicate
        }
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
                
                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
                //we also want to potentially have a null value substituted
                if let value = valueConvertible.evaluate() {
                    substitutions[key] = value
                }
                else {
                    //                    assertionFailure("Added NSNull support for this type")
                    let nilObject: AnyObject? = nil as AnyObject?
                    substitutions[key] = nilObject as Any
                }
                
            }
            
        })
        
        log?.substitutions = substitutions
        log?.status = "Generated Substitutions"
        
        guard substitutions.count == substitutionsJSON.count else {
            return nil
        }
        
        let predicateWithSubstitutions = nsPredicate.withSubstitutionVariables(substitutions)
        log?.nsPredicate = predicateWithSubstitutions
        return predicateWithSubstitutions
    }
    
//    public static func generatePredicateExpression(predicate: RSPredicate, state: RSState, context: [String: AnyObject], log: RSPredicateLog? = nil) -> RSPredicateExpression? {
//
//        return RSApplicationDelegate.appDelegate.predicateManager.generatePredicateExpression(
//            predicate:predicate,
//            state: state,
//            context: context,
//            log: log
//        )
//
//    }
    
    public static func generatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject], log: RSPredicateLog? = nil) -> NSPredicate? {
        
        return RSApplicationDelegate.appDelegate.predicateManager.generatePredicate(
            predicate:predicate,
            state: state,
            context: context,
            log: log
        )
        
    }
    
    public static func apply(predicate: RSPredicate, to array: [AnyObject], state: RSState, context: [String: AnyObject]) -> [AnyObject] {
        
        var log = RSPredicateLog(predicate: predicate)
        
        defer {
            RSApplicationDelegate.appDelegate.predicateManager.delegate?.log(log: log)
        }
        
        guard let nsPredicate = self.generatePredicate(predicate: predicate, state: state, context: context, log: log) else {
            return []
        }
        
//        debugPrint(array)
        
        array.forEach { (element) in
//            debugPrint(element)
        }
        
        log.status = "Applying To Array"
        
        let arrayToApplyTo = array as NSArray
        let filteredArray = arrayToApplyTo.filtered(using: nsPredicate) as [AnyObject]
        
//        if let predicateExpression = self.generatePredicateExpression(predicate: predicate, state: state, context: context, log: log) {
//            
//            do {
////                let newEvaluatesTo = try predicateExpression.evaluate(with: [:])
//                let newFilteredArray = try predicateExpression.filter(array: arrayToApplyTo) as [AnyObject]
//                assert(newFilteredArray.count == filteredArray.count)
//                zip(filteredArray, newFilteredArray).forEach { (pair) in
//                    assert(pair.0 as! NSObject == pair.1 as! NSObject)
//                }
//
//            }
//            catch let e {
//                print(e)
//                assertionFailure()
//            }
//            
//            print(predicateExpression)
//            
//        }
//        else {
//            assertionFailure("Could not generate predicate expression")
//        }
        
        return filteredArray
    }
    
    public static func evaluatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> Bool {
        //construct substitution dictionary
        
        var log = RSPredicateLog(predicate: predicate)
        
        defer {
            RSApplicationDelegate.appDelegate.predicateManager.delegate?.log(log: log)
        }
        
        guard let nsPredicate = self.generatePredicate(predicate: predicate, state: state, context: context, log: log) else {
                return false
        }
        
        let evaluatesTo = nsPredicate.evaluate(with: nil)
        log.status = "Evaluated"
        log.evaluated = evaluatesTo
        
//        if let predicateExpression = self.generatePredicateExpression(predicate: predicate, state: state, context: context, log: log) {
//
//            do {
//                let newEvaluatesTo = try predicateExpression.evaluate(with: nil)
//                assert(newEvaluatesTo == evaluatesTo)
//            }
//            catch let e {
//                print(e)
//                assertionFailure()
//            }
//
//        }
//        else {
//            assertionFailure("Could not generate predicate expression")
//        }
        
        return evaluatesTo
        
    }

}
