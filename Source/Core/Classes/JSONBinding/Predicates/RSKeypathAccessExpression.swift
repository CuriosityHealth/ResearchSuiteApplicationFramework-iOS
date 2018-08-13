//
//  RSKeypathAccessExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSKeypathAccessExpression: RSExpression {
    
    let left: RSExpression
    let operation: RSExpressionToken
    let right: RSExpressionToken
    
    init(left: RSExpression, operation: RSExpressionToken, right: RSExpressionToken) {
        self.left = left
        self.operation = operation
        self.right = right
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        
        let rootValue = try left.evaluate(substitutions: substitutions, context: context)
        
        assert(operation.type == .dot)
        assert(right.type == .implicitVariable)
        
        let key = right.value as! String
        
        return rootValue.value(forKeyPath: key) as! NSObject
    }

}
