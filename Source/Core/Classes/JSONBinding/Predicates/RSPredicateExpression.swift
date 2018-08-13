//
//  RSPredicateExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

open class RSPredicateExpression: RSBooleanExpression {
    
    static func generateExpression(format: String) throws -> RSPredicateExpression {
        
        let tokens = try RSExpressionTokenizer.generateTokens(text: format)
        let rootExpression = try RSExpressionParser.generateExpression(tokens: tokens)
        
        return RSPredicateExpression(rootExpression: rootExpression)
    }
    
    let rootExpression: RSBooleanExpression
    let substitutions: [String: NSObject]?
    init(rootExpression: RSBooleanExpression, substitutions: [String: NSObject]? = nil) {
        self.rootExpression = rootExpression
        self.substitutions = substitutions
    }
    
    func evaluate(substitutions: [String : NSObject], context: NSObject?) throws -> Bool {
        return try self.rootExpression.evaluate(substitutions: substitutions, context: context)
    }
    
    func withSubstitutions(substitutions: [String: NSObject]) -> RSPredicateExpression {
        return RSPredicateExpression(rootExpression: self.rootExpression, substitutions: substitutions)
    }
    
    func evaluate(with context: NSObject?) throws -> Bool {
        return try self.evaluate(substitutions: self.substitutions ?? [String: NSObject](), context: context)
    }
    
    func filter(array: NSArray) throws -> NSArray {
        
        let filteredArray = try array.filter { (element) -> Bool in
            
            guard let context = element as? NSObject else {
                return false
            }
            
            return try self.evaluate(with: context)
            
        }.compactMap { $0 as? NSObject } as NSArray
        
        return filteredArray
        
    }
    
}
