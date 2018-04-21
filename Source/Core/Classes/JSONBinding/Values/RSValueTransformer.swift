//
//  RSValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public protocol RSValueTransformer {
    
    static func supportsType(type: String) -> Bool
    static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible?

}
