//
//  RSActionManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Gloss
import ReSwift


public protocol RSActionManagerProvider {
    var actionManager: RSActionManager! { get }
    func processAction(action: JSON, context: [String: AnyObject], store: Store<RSState>)
    func processActions(actions: [JSON], context: [String: AnyObject], store: Store<RSState>)
}

public struct RSApplicationActionLog: JSONEncodable {
    
    
    let action: JSON
    let uuid: UUID
    let timestamp: Date
    var malformedAction = false
    var predicateResult: Bool? = nil
    var successfulTransforms: [String] = []
    
    public func toJSON() -> JSON? {
        
        return jsonify([
            "action" ~~> self.action,
            "uuid" ~~> self.uuid,
            Gloss.Encoder.encode(dateISO8601ForKey: "timestamp")(self.timestamp),
            "malformedAction" ~~> self.malformedAction,
            "predicateResult" ~~> self.predicateResult,
            "successfulTransforms" ~~> self.successfulTransforms
            ])
    }
    
    public init(action: JSON) {
        self.action = action
        self.uuid = UUID()
        self.timestamp = Date()
    }
    
}

public protocol RSActionManagerDelegate: class {
    func logAction(actionLog: RSApplicationActionLog)
}



open class RSActionManager: NSObject {
    
    public weak var delegate: RSActionManagerDelegate?
    
    let actionCreatorTransforms: [RSActionTransformer.Type]
    
    public init(
        actionCreatorTransforms: [RSActionTransformer.Type]?
        ) {
        self.actionCreatorTransforms = actionCreatorTransforms ?? []
        super.init()
    }
    
    open func processAction(action: JSON, context: [String: AnyObject], store: Store<RSState>) {
        
        var actionLog = RSApplicationActionLog(action: action)
        
        defer {
            self.delegate?.logAction(actionLog: actionLog)
        }
        
        //check for predicate and evaluate
        //if predicate exists and evaluates false, do not execute action
        if let predicate: RSPredicate = "predicate" <~~ action {
            let predicateResult = RSPredicateManager.evaluatePredicate(predicate: predicate, state: store.state, context: context)
            actionLog.predicateResult = predicateResult
            if !predicateResult {
                return
            }
        }
        
        //if action malformed, do not execute action
        guard let actionType: String = "type" <~~ action else {
            actionLog.malformedAction = true
            return
        }

        self.actionCreatorTransforms.forEach { transformer in
            if transformer.supportsType(type: actionType),
                let actionClosure = transformer.generateAction(jsonObject: action, context: context, actionManager: self) {
                
                let transformerString = "\(type(of: transformer))"
                actionLog.successfulTransforms = actionLog.successfulTransforms + [transformerString]
                
                store.dispatch(actionClosure)
            }
        }
    
    }
    
    open func processActions(actions: [JSON], context: [String: AnyObject], store: Store<RSState>) {
        actions.forEach { self.processAction(action: $0, context: context, store: store) }
    }

}
