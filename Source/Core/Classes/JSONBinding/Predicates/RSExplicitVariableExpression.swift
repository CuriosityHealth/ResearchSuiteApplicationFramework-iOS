//
//  RSExplicitVariableExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSExplicitVariableExpression: RSExpression {
    let token: RSExpressionToken
    init(token: RSExpressionToken) {
        assert(token.type == .explicitVariable)
        self.token = token
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        let variableName = (self.token.value as! String)
        return substitutions[variableName]!
    }
}
