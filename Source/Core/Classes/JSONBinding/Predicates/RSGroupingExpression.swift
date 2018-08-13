//
//  RSGroupingExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSGroupingExpression: RSBooleanExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        return try self.expr.evaluate(substitutions: substitutions, context: context)
    }
    
    let expr: RSBooleanExpression
    init(expr: RSBooleanExpression) {
        self.expr = expr
    }

}
