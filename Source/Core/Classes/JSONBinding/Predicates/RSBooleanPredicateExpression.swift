//
//  RSBooleanPredicateExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSBooleanPredicateExpression: RSBooleanExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool {
        switch self.predicate.type {
        case .truepredicate:
            return true
        case .falsepredicate:
            return false
        default:
            throw RSExpressionParserError.invalidToken("invalid token \(self.predicate) found in RSBoolPredicateExpression")
        }
    }
    
    let predicate: RSExpressionToken
    init(predicate: RSExpressionToken) {
        self.predicate = predicate
    }

}
