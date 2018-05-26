//
//  RSActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ReSwift

public protocol RSActionTransformer {

    static func supportsType(type: String) -> Bool
    //this return a closure, of which state and store are injected
    static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)?
    
}

public protocol RSURLToJSONActionConverter {
    static func supportsURLType(type: String) -> Bool
    static func convertURLToJSONAction(queryParams: [String: String], context: [String: AnyObject], store: Store<RSState>) -> JSON?
}
