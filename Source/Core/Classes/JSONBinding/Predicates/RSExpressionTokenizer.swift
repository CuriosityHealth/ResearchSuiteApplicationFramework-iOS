//
//  RSExpressionTokenizer.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

/// Errors thrown a problem is encountered while tokenizing a string.
public enum RSExpressionTokenError: Error {
    
    /// A token that looked like an integer could not be converted to `Int`.
    case malformedInteger
    
    /// A character was found in the input string that is not recognized by the
    /// tokenizer.
    case unrecognizedCharacter
    
    /// The end of the input string was reached while scanning a quoted string.
    case unterminatedString
    
    case unexpectedCharacter(Character)
}

struct RSExpressionTokenizer {
    
    private var iterator: String.Iterator
    private var pushedBackCharacter: Character?
    
    init(text: String) {
        iterator = text.makeIterator()
    }
    
    static func generateTokens(text: String) throws -> [RSExpressionToken] {
        
        var tokenizer = RSExpressionTokenizer(text: text)
        var tokens:[RSExpressionToken] = []
        
        while let token = try tokenizer.nextToken() {
            tokens.append(token)
        }
        
        tokens.append(RSExpressionToken(type: .eof, value: nil))
        return tokens
    }
    
    mutating func nextToken() throws -> RSExpressionToken? {
        while let ch = nextCharacter() {
            switch ch {
            case " ", "\n", "\r", "\t":
                // Ignore whitespace.
                continue
            case "%":
                return RSExpressionToken(type: .percent, value: nil)
            case "@":
                return RSExpressionToken(type: .at, value: nil)
            case "(":
                return RSExpressionToken(type: .leftParen, value: nil)
            case ")":
                return RSExpressionToken(type: .rightParen, value: nil)
            case "[":
                return RSExpressionToken(type: .leftSquareBrace, value: nil)
            case "]":
                return RSExpressionToken(type: .rightSquareBrace, value: nil)
            case "{":
                return RSExpressionToken(type: .leftCurlyBrace, value: nil)
            case "}":
                return RSExpressionToken(type: .rightCurlyBrace, value: nil)
            case ",":
                return RSExpressionToken(type: .comma, value: nil)
            case ".":
                return RSExpressionToken(type: .dot, value: nil)
                
            case "=":
                return try equalsToken()
                
            case "<":
                return try lessThanToken()
                
            case ">":
                return try greaterThanToken()
                
            case "!":
                return try bangToken()
                
            case "&":
                return try ampToken()
                
            case "|":
                return try pipeToken()
                
            case "$":
                return try explicitVariableToken()
                
                //            case ",":
                //                return .comma
                //            case ";":
            //                return .semicolon
            case "0"..."9", "-":
                return try integerToken(startingWith: ch)
            case "\"":
                return try stringToken()
            case "a"..."z", "A"..."Z":
                return try reservedStringToken(startingWith: ch)
                
            default:
                throw RSExpressionTokenError.unrecognizedCharacter
            }
        }
        return nil
    }
    
    private mutating func nextCharacter() -> Character? {
        if let next = pushedBackCharacter {
            pushedBackCharacter = nil
            return next
        }
        return iterator.next()
    }
    
    private mutating func equalsToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case " ", "\n", "\r", "\t":
            return RSExpressionToken(type: .equal, value: nil)
        case "=":
            return RSExpressionToken(type: .equalEqual, value: nil)
        case ">":
            return RSExpressionToken(type: .egt, value: nil)
        case "<":
            return RSExpressionToken(type: .elt, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    private mutating func lessThanToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case " ", "\n", "\r", "\t":
            return RSExpressionToken(type: .lt, value: nil)
        case "=":
            return RSExpressionToken(type: .lte, value: nil)
        case ">":
            return RSExpressionToken(type: .angleNotEqual, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    private mutating func greaterThanToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case " ", "\n", "\r", "\t":
            return RSExpressionToken(type: .gt, value: nil)
        case "=":
            return RSExpressionToken(type: .gte, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    private mutating func bangToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case " ", "\n", "\r", "\t":
            return RSExpressionToken(type: .bang, value: nil)
        case "=":
            return RSExpressionToken(type: .bangNotEqual, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    private mutating func ampToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case "&":
            return RSExpressionToken(type: .doubleAmp, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    private mutating func pipeToken() throws -> RSExpressionToken {
        
        let ch = nextCharacter()
        
        switch ch {
        case "|":
            return RSExpressionToken(type: .doubleLine, value: nil)
        default:
            throw RSExpressionTokenError.unexpectedCharacter(ch!)
        }
        
    }
    
    let wordCharacterSet = CharacterSet(charactersIn: "_").union(CharacterSet.alphanumerics)
    
    private func isWordCharacter(ch: Character) -> Bool {
        let chString = String(ch)
        return chString.rangeOfCharacter(from: self.wordCharacterSet) != nil
    }
    
    private mutating func explicitVariableToken() throws -> RSExpressionToken {
        var tokenText = String()
        var found = false
        
        while let ch = nextCharacter() {
            switch ch {
            case " ", "\n", "\r", "\t":
                return RSExpressionToken(type: .explicitVariable, value: tokenText)
            default:
                if self.isWordCharacter(ch: ch) {
                    tokenText.append(ch)
                }
                else {
                    found = true
                    self.pushedBackCharacter = ch
                    break
                }
            }
            
            if found {
                break
            }
        }
        
        //if hit end of input, return variable
        return RSExpressionToken(type: .explicitVariable, value: tokenText)
    }

    private mutating func reservedStringToken(startingWith first: Character) throws -> RSExpressionToken {
        var tokenText = String(first)
        var found = false
        
        while let ch = nextCharacter() {
            switch ch {
            case " ", "\n", "\r", "\t":
                found = true
                break
            default:
                if self.isWordCharacter(ch: ch) {
                    tokenText.append(ch)
                }
                else {
                    found = true
                    self.pushedBackCharacter = ch
                    break
                }
                
            }
            
            if found {
                break
            }
        }
        
        
        switch tokenText.lowercased() {
            
        case "truepredicate":
            return RSExpressionToken(type: .truepredicate, value: nil)
            
        case "falsepredicate":
            return RSExpressionToken(type: .falsepredicate, value: nil)
            
        case "and":
            return RSExpressionToken(type: .andString, value: nil)
            
        case "or":
            return RSExpressionToken(type: .orString, value: nil)
            
        case "not":
            return RSExpressionToken(type: .notString, value: nil)
            
        case "false":
            return RSExpressionToken(type: .falseString, value: nil)
            
        case "true":
            return RSExpressionToken(type: .trueString, value: nil)
            
        case "null":
            return RSExpressionToken(type: .nullString, value: nil)
            
        case "nil":
            return RSExpressionToken(type: .nilString, value: nil)
            
        case "self":
            return RSExpressionToken(type: .selfString, value: nil)
            
        case "first":
            return RSExpressionToken(type: .firstString, value: nil)
            
        case "last":
            return RSExpressionToken(type: .lastString, value: nil)
            
        case "size":
            return RSExpressionToken(type: .sizeString, value: nil)
            
        case "any":
            return RSExpressionToken(type: .anyString, value: nil)
            
        case "some":
            return RSExpressionToken(type: .someString, value: nil)
            
        case "all":
            return RSExpressionToken(type: .allString, value: nil)
            
        case "none":
            return RSExpressionToken(type: .noneString, value: nil)
            
        case "in":
            return RSExpressionToken(type: .inString, value: nil)
            
        case "beginswith":
            return RSExpressionToken(type: .beginswith, value: nil)
            
        case "contains":
            return RSExpressionToken(type: .contains, value: nil)
            
        case "endswith":
            return RSExpressionToken(type: .endswith, value: nil)
            
        case "like":
            return RSExpressionToken(type: .like, value: nil)
            
        case "matches":
            return RSExpressionToken(type: .matches, value: nil)
            
        default:
            return RSExpressionToken(type: .implicitVariable, value: tokenText)
            
        }
        
    }
    
    private mutating func stringToken() throws -> RSExpressionToken {
        var tokenText = String()
        var terminated = false
        while let ch = nextCharacter() {
            switch ch {
            case "\"":
                terminated = true
                break
            default:
                tokenText.append(ch)
            }
            
            if terminated {
                break
            }
        }
        
        if !terminated {
            throw RSExpressionTokenError.unterminatedString
        }
        
        return RSExpressionToken(type: .stringLiteral, value: tokenText)
        
    }
    
    private mutating func integerToken(startingWith first: Character) throws -> RSExpressionToken {
        var tokenText = String(first)
        
        loop: while let ch = nextCharacter() {
            switch ch {
            case "0"..."9":
                tokenText.append(ch)
            default:
                pushedBackCharacter = ch
                break loop
            }
        }
        
        guard let value = Int(tokenText) else {
            throw RSExpressionTokenError.malformedInteger
        }
        
        return RSExpressionToken(type: .intLiteral, value: value)
    }
    
}
