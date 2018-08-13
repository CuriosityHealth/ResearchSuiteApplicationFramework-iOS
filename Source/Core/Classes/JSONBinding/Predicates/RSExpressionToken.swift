//
//  RSExpressionToken.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

public enum RSExpressionTokenType {
    
    case eof
    //    special characters
    //    case dollar
    case percent
    case at
    case leftParen
    case rightParen
    case leftSquareBrace
    case rightSquareBrace
    case leftCurlyBrace
    case rightCurlyBrace
    case comma
    case dot
    
    //do we need to worry about escaping anything??
    
    //    Basic Comparisons
    case equal
    case equalEqual
    case gte
    case egt
    case lte
    case elt
    case gt
    case lt
    case bangNotEqual
    case angleNotEqual
    
    case between
    
    //    Boolean Value Predicates
    
    case truepredicate
    case falsepredicate
    
    //    Basic Compound Predicates
    case andString
    case doubleAmp
    case orString
    case doubleLine
    
    //unary
    case notString
    case bang
    
    //String comparisons
    case beginswith
    case contains
    case endswith
    case like
    case matches
    case utiConformsTo
    case utiEquals
    
    //    aggregate operations
    case anyString
    case someString
    case allString
    case noneString
    case inString
    
    //array operations
    case firstString
    case lastString
    case sizeString
    
    
    //    reserved literals
    case falseString
    case trueString
    case noString
    case yesString
    case nullString
    case nilString
    case selfString
    
    case stringLiteral
    case intLiteral
    
    case explicitVariable
    case implicitVariable
    
}

public struct RSExpressionToken: CustomStringConvertible {
    public let type: RSExpressionTokenType
    public let value: Any?
    
    public var description: String {
        
        if let value = self.value {
            return "RSToken:(\(self.type): \(value))"
        }
        else {
            return "RSToken:(\(self.type))"
        }
    }
}
