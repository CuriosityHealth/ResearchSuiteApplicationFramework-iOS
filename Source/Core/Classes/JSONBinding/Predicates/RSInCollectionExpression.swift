//
//  RSInCollectionExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSInCollectionExpression: RSBooleanExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        
        assert(self.operation.type == .inString)
        
        let leftValue = try self.left.evaluate(substitutions: substitutions, context: context)
        let rightValue = try self.right.evaluate(substitutions: substitutions, context: context) as! NSArray
        
        return rightValue.contains(leftValue)
        
    }
    
    let left: RSExpression
    let operation: RSExpressionToken
    let right: RSExpression
    
    init(left: RSExpression, operation: RSExpressionToken, right: RSExpression) {
        self.left = left
        assert(operation.type == .inString)
        self.operation = operation
        self.right = right
    }

}
