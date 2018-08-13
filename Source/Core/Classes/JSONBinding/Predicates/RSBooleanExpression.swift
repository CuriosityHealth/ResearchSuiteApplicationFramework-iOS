//
//  RSBooleanExpression.swift
//  Pods
//
//  Created by James Kizer on 8/12/18.
//

import UIKit

protocol RSBooleanExpression {
    func evaluate(substitutions: [String: NSObject], context: NSObject?) throws -> Bool
}
