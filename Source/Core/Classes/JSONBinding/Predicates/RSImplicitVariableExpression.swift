//
//  RSImplicitVariableExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSImplicitVariableExpression: RSExpression {
    
    let token: RSExpressionToken
    init(token: RSExpressionToken) {
        assert(token.type == .implicitVariable)
        self.token = token
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        let variableName = (self.token.value as! String)
        
        guard let obj = context else {
            throw RSExpressionParserError.evaluationError("For implicit variables, context must not be nil")
        }
        
        return obj.value(forKey: variableName) as! NSObject
    }

}
