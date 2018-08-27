//
//  RSExpressionParser.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

enum RSExpressionParserError: Error {
    case invalidToken(String)
    case evaluationError(String)
}

class RSExpressionParser {
    
    static func generateExpression(tokens: [RSExpressionToken]) throws -> RSBooleanExpression {
        
        let parser = RSExpressionParser(tokens: tokens)
        return try parser.expression()
        
    }
    
    var currentToken: RSExpressionToken {
        return self.tokens[self.current]
    }
    
    var previousToken: RSExpressionToken {
        return self.tokens[self.current-1]
    }
    
    var isAtEnd: Bool {
        return self.currentToken.type == RSExpressionTokenType.eof
    }
    
    @discardableResult
    func advance() -> RSExpressionToken {
        if (!self.isAtEnd) { self.current = self.current + 1 }
        return self.previousToken
    }
    
    func check(tokenType: RSExpressionTokenType) -> Bool {
        if self.isAtEnd { return false }
        return self.currentToken.type == tokenType
    }
    
    @discardableResult
    func consume(tokenType: RSExpressionTokenType) throws -> RSExpressionToken {
        if self.check(tokenType: tokenType) { return advance() }
        throw RSExpressionParserError.invalidToken("Expecting \(tokenType), got \(self.currentToken.type)")
    }
    
    func match(tokenTypes: [RSExpressionTokenType], advance: Bool = true) -> Bool {
        
        if self.isAtEnd { return false }
        
        let tokenType = self.currentToken.type
        
        if tokenTypes.contains(tokenType) {
            if advance { self.advance() }
            return true
        }
        else {
            return false
        }
    }
    
    //turns list of tokens into an expression
    //thows if it cannot form an expression
    func parse() throws -> RSBooleanExpression {
        
        return try self.expression()
        
    }
    
    func expression() throws -> RSBooleanExpression {
        
        var expr = try self.orTermExpression()
        while(match(tokenTypes: [.orString, .doubleLine])) {
            
            let op = self.previousToken
            let right = try self.orTermExpression()
            expr = RSCompoundLogicalExpression(left: expr, operation: op, right: right)
            
        }
        
        return expr
        
    }
    
    func orTermExpression() throws -> RSBooleanExpression {
        var expr = try self.unaryExpression()
        while(match(tokenTypes: [.andString, .doubleAmp])) {
            
            let op = self.previousToken
            let right = try self.unaryExpression()
            expr = RSCompoundLogicalExpression(left: expr, operation: op, right: right)
            
        }
        
        return expr
    }
    
    func unaryExpression() throws -> RSBooleanExpression {
        if (match(tokenTypes: [.bang])) {
            let op = self.previousToken
            let right = try self.unaryExpression()
            return RSNegativeLogicalExpression(operation: op, expr: right)
        }
        else {
            return try self.primaryExpression()
        }
    }
    
    
    func primaryExpression() throws -> RSBooleanExpression {
        if (match(tokenTypes: [.truepredicate, .falsepredicate])) {
            let predicate = self.previousToken
            return RSBooleanPredicateExpression(predicate: predicate)
        }
        else if (match(tokenTypes: [.leftParen])) {
            let expr = try self.expression()
            try self.consume(tokenType: .rightParen)
            return RSGroupingExpression(expr: expr)
        }
        else {
            
            let saveCurrent = self.current
            
            do {
                let expr = try self.comparisonPredicateExpression()
                return expr
            }
            catch let e {
//                print(e)
                self.current = saveCurrent
            }
            
            do {
                let expr = try self.stringPredicateExpression()
                return expr
            }
            catch let e {
//                print(e)
                self.current = saveCurrent
            }
            
            do {
                let expr = try self.inCollectionPredicateExpression()
                //                print("got collection expression \(expr)")
                return expr
            }
            catch let e {
//                print(e)
                self.current = saveCurrent
            }
            
            throw RSExpressionParserError.invalidToken("Could not match \(self.currentToken)")
            
        }
    }
    
    func comparisonPredicateExpression() throws -> RSBooleanExpression {
        
        let left = try parserValue()
        let operation = try comparisonOperation()
        let right = try parserValue()
        
        return RSComparisonExpression(left: left, operation: operation, right: right)
        
    }
    
    //start off by only matching string and int literals
    func parserValue() throws -> RSExpression {
        
        if (match(tokenTypes: [
            .stringLiteral,
            .intLiteral,
            .falseString, .noString,
            .trueString, .yesString,
            .nilString, .nullString
            ])) {
            return try RSLiteralExpression(token: self.previousToken)
        }
            
        else if (match(tokenTypes: [.selfString])) {
            return try RSSelfExpression(token: self.previousToken)
        }
            
        else if (match(tokenTypes: [.explicitVariable])) {
            return try self.explicitVariableExpressionValue()
        }
            
        else if (match(tokenTypes: [.implicitVariable])) {
            return try self.implicitVariableExpressionValue()
        }
            
        else {
            throw RSExpressionParserError.invalidToken("Expected value, got \(self.currentToken)")
        }
        
    }
    
    func explicitVariableExpressionValue() throws -> RSExpression {
        
        var expr:RSExpression = RSExplicitVariableExpression(token: self.previousToken)
        while(match(tokenTypes: [.dot, .leftSquareBrace])) {
            switch self.previousToken.type {
            case .dot:
                let op = self.previousToken
                let right = try self.consume(tokenType: .implicitVariable)
                expr = RSKeypathAccessExpression(left: expr, operation: op, right: right)
                
            case .leftSquareBrace:
                let op = self.previousToken
                if (match(tokenTypes: [.firstString, .lastString, .sizeString])) {
                    let right = self.previousToken
                    expr = RSCollectionElementSpecialAccessExpression(left: expr, operation: op, right: right)
                }
                else {
                    let right = try self.parserValue()
                    expr = RSCollectionElementIndexedAccessExpression(left: expr, operation: op, right: right)
                }
                
                try self.consume(tokenType: .rightSquareBrace)
                
            default:
                throw RSExpressionParserError.invalidToken("Expected dot or brace operator, got \(self.previousToken)")
                
            }
        }
        
        return expr
        
    }
    
    func implicitVariableExpressionValue() throws -> RSExpression {
        
        var expr:RSExpression = RSImplicitVariableExpression(token: self.previousToken)
        while(match(tokenTypes: [.dot, .leftSquareBrace])) {
            switch self.previousToken.type {
            case .dot:
                let op = self.previousToken
                let right = try self.consume(tokenType: .implicitVariable)
                expr = RSKeypathAccessExpression(left: expr, operation: op, right: right)
                
            case .leftSquareBrace:
                let op = self.previousToken
                if (match(tokenTypes: [.firstString, .lastString, .sizeString])) {
                    let right = self.previousToken
                    expr = RSCollectionElementSpecialAccessExpression(left: expr, operation: op, right: right)
                }
                else {
                    let right = try self.parserValue()
                    expr = RSCollectionElementIndexedAccessExpression(left: expr, operation: op, right: right)
                }
                
                try self.consume(tokenType: .rightSquareBrace)
                
            default:
                throw RSExpressionParserError.invalidToken("Expected dot or brace operator, got \(self.previousToken)")
                
            }
        }
        
        return expr
        
    }

    func comparisonOperation() throws -> RSExpressionToken {
        
        if (match(tokenTypes: [
            .equal, .equalEqual,
            .bangNotEqual, .angleNotEqual,
            .gte, .egt, .gt,
            .lte, .elt, .lt ])) {
            return self.previousToken
        }
        else {
            throw RSExpressionParserError.invalidToken("Expected comparison operation, got \(self.currentToken)")
        }
        
    }
    
    
    
    func stringPredicateExpression() throws -> RSBooleanExpression {
        throw RSExpressionParserError.invalidToken("Expecting predicate literal token but got \(self.currentToken)")
    }
    
    func inCollectionPredicateExpression() throws -> RSBooleanExpression {
        
        let left = try parserValue()
        let operation = try inCollectionOperation()
        let right = try parserValue()
        
        return RSInCollectionExpression(left: left, operation: operation, right: right)
        
    }
    
    func inCollectionOperation() throws -> RSExpressionToken {
        
        if (match(tokenTypes: [.inString])) {
            return self.previousToken
        }
        else {
            throw RSExpressionParserError.invalidToken("Expected collection operation, got \(self.currentToken)")
        }
        
    }
    
    
    
    
    let tokens: [RSExpressionToken]
    var current = 0
    
    init(tokens: [RSExpressionToken]) {
        self.tokens = tokens
    }
    
}
