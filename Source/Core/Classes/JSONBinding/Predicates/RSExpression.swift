//
//  RSExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

protocol RSExpression {
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject
    func equals(_ other: RSExpression, substitutions: [String: NSObject], context: NSObject?) throws -> Bool
    func greaterThan(_ other: RSExpression, substitutions: [String: NSObject], context: NSObject?) throws -> Bool
}

extension RSExpression {
    
    func equals(_ other: RSExpression, substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        let value = try self.evaluate(substitutions: substitutions, context: context)
        let otherValue = try other.evaluate(substitutions: substitutions, context: context)
        
        return value == otherValue
    }
    
    func greaterThan(_ other: RSExpression, substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        let v = try self.evaluate(substitutions: substitutions, context: context)
        
        switch v {
            
        case let s as String:
            
            guard let os = try other.evaluate(substitutions: substitutions, context: context) as? String else {
                throw RSExpressionParserError.evaluationError("incompatible types")
            }
            
            return s > os
            
        case let i as Int:
            
            guard let oi = try other.evaluate(substitutions: substitutions, context: context) as? Int else {
                throw RSExpressionParserError.evaluationError("incompatible types")
            }
            
            return i > oi
            
        case let d as Date:
            
            guard let od = try other.evaluate(substitutions: substitutions, context: context) as? Date else {
                throw RSExpressionParserError.evaluationError("incompatible types")
            }
            
            return d > od
            
        default:
            throw RSExpressionParserError.evaluationError("incompatible types")
        }
        
    }
    
}
