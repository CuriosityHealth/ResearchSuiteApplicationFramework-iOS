//
//  RSLiteralExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSLiteralExpression: RSExpression {
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        return self.literal
    }
    
    let token: RSExpressionToken
    let literal: NSObject
    init(token: RSExpressionToken) throws {
        self.token = token
        
        switch token.type {
        case .intLiteral, .stringLiteral:
            self.literal = token.value as! NSObject
        case .yesString, .trueString:
            self.literal = NSNumber(booleanLiteral: true)
        case .noString, .falseString:
            self.literal = NSNumber(booleanLiteral: false)
        case .nullString, .nilString:
            self.literal = NSNull()
        default:
            throw RSExpressionParserError.invalidToken("Invalid literal token type \(token.type)")
        }
    }

}
