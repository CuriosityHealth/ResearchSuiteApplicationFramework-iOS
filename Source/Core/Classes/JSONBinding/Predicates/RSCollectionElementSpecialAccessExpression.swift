//
//  RSCollectionElementSpecialAccessExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

class RSCollectionElementSpecialAccessExpression: RSExpression {
    
    let left: RSExpression
    let operation: RSExpressionToken
    let right: RSExpressionToken
    
    init(left: RSExpression, operation: RSExpressionToken, right: RSExpressionToken) {
        self.left = left
        self.operation = operation
        self.right = right
    }
    
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> NSObject {
        
        let array = try left.evaluate(substitutions: substitutions, context: context) as! NSArray
        
        switch self.right.type {
        case .firstString:
            return array[0] as! NSObject
        case .lastString:
            return array[array.count - 1] as! NSObject
        case .sizeString:
            return array.count as NSObject
        default:
            throw RSExpressionParserError.invalidToken("Unsupported token for collection access \(self.right.type)")
        }
        
    }

}
