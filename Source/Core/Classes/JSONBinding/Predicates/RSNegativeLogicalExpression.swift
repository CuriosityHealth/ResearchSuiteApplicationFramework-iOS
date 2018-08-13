//
//  RSNegativeLogicalExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSNegativeLogicalExpression: RSBooleanExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        switch self.operation.type {
        case .bang:
            return try !self.expr.evaluate(substitutions: substitutions, context: context)
        default:
            throw RSExpressionParserError.invalidToken("invalid token \(self.operation) found in RSUnaryExpression")
        }
        
    }
    
    let operation: RSExpressionToken
    let expr: RSBooleanExpression
    
    init(operation: RSExpressionToken, expr: RSBooleanExpression) {
        self.operation = operation
        self.expr = expr
    }
    
}
