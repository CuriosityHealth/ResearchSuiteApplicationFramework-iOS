//
//  RSComparisonExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSComparisonExpression: RSBooleanExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        switch self.operation.type {
        case .equal, .equalEqual:
            return try self.left.equals(self.right, substitutions: substitutions, context: context)
        case .bangNotEqual, .angleNotEqual:
            return try !self.left.equals(self.right, substitutions: substitutions, context: context)
        case .gte, .egt:
            let greaterThan = try self.left.greaterThan(self.right, substitutions: substitutions, context: context)
            let equalTo = try self.left.equals(self.right, substitutions: substitutions, context: context)
            return greaterThan || equalTo
        case .gt:
            return try self.left.greaterThan(self.right, substitutions: substitutions, context: context)
        case .lte, .elt:
            return try !self.left.greaterThan(self.right, substitutions: substitutions, context: context)
        case .lt:
            let greaterThan = try self.left.greaterThan(self.right, substitutions: substitutions, context: context)
            let equalTo = try self.left.equals(self.right, substitutions: substitutions, context: context)
            return !(greaterThan || equalTo)
            
        default:
            throw RSExpressionParserError.evaluationError("Cannot compare \(left) and \(right) via \(operation)")
        }
        
    }
    
    
    let left: RSExpression
    let operation: RSExpressionToken
    let right: RSExpression
    
    init(left: RSExpression, operation: RSExpressionToken, right: RSExpression) {
        self.left = left
        self.operation = operation
        self.right = right
    }

}
