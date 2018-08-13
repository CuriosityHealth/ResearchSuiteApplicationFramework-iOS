//
//  RSCompoundLogicalExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSCompoundLogicalExpression: RSBooleanExpression {
    
    let left: RSBooleanExpression
    let operation: RSExpressionToken
    let right: RSBooleanExpression
    
    init(left: RSBooleanExpression, operation: RSExpressionToken, right: RSBooleanExpression) {
        self.left = left
        self.operation = operation
        self.right = right
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        switch self.operation.type {
        case .andString:
            fallthrough
        case .doubleAmp:
            return try self.left.evaluate(substitutions: substitutions, context: context) && self.right.evaluate(substitutions: substitutions, context: context)
            
        case .orString:
            fallthrough
        case .doubleLine:
            return try self.left.evaluate(substitutions: substitutions, context: context) || self.right.evaluate(substitutions: substitutions, context: context)
            
            
        default:
            throw RSExpressionParserError.invalidToken("invalid token \(self.operation) found in RSCompoundLogicalExpression")
        }
        
    }

}
