//
//  RSActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/25/17.
//
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ReSwift

public protocol RSActionTransformer {

    static func supportsType(type: String) -> Bool
    //this return a closure, of which state and store are injected
    static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)?
    
}
