//
//  RSSelfExpression.swift
//  Pods
//
//  Created by James Kizer on 8/13/18.
//

import UIKit

class RSSelfExpression: RSExpression {
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        guard let context = context else {
            throw RSExpressionParserError.evaluationError("Null Context")
        }
        return context
    }
    
    let token: RSExpressionToken
    init(token: RSExpressionToken) throws {
        assert(token.type == .selfString)
        
        if (token.type != .selfString) {
            throw RSExpressionParserError.invalidToken("Invalid self token type \(token.type)")
        }
    
        self.token = token
    }
}
