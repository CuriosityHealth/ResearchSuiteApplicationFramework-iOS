//
//  RSCollectionElementIndexedAccessExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSCollectionElementIndexedAccessExpression: RSExpression {
    let left: RSExpression
    let operation: RSExpressionToken
    let right: RSExpression
    
    init(left: RSExpression, operation: RSExpressionToken, right: RSExpression) {
        self.left = left
        self.operation = operation
        self.right = right
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        
        let array = try left.evaluate(substitutions: substitutions, context: context) as! NSArray
        assert(operation.type == .leftSquareBrace)
        let rightValue = try self.right.evaluate(substitutions: substitutions, context: context) as! Int
        return array[rightValue] as! NSObject
        
    }
}
