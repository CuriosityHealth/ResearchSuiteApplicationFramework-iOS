//
//  RSActivityManager.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSActivityManager: NSObject, StoreSubscriber {
    
    let store: Store<RSState>
    
    weak var delegate: UIViewController?
    let delegateLock: DispatchQueue
    
    var isLaunching = false
    
    static let defaultActivityElementTransforms: [RSActivityElementTransformer.Type] = [
        RSMeasureActivityElementTransformer.self,
        RSInstructionActivityElementTransformer.self
    ]
    
    let activityElementTransforms: [RSActivityElementTransformer.Type]
    
    let taskBuilder: RSTBTaskBuilder
    let stepTreeBuilder: RSStepTreeBuilder
    
    init(
        store: Store<RSState>,
        taskBuilder: RSTBTaskBuilder,
        stepTreeBuilder: RSStepTreeBuilder,
        activityElementTransforms: [RSActivityElementTransformer.Type] = RSActivityManager.defaultActivityElementTransforms
        ) {
        
        self.store = store
        self.delegateLock = DispatchQueue(label: "RSActivityManager.delegateLock")
        self.taskBuilder = taskBuilder
        self.activityElementTransforms = activityElementTransforms
        self.stepTreeBuilder = stepTreeBuilder
        
        super.init()
        
        self.store.subscribe(self)
        
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    private func getDelegate() -> UIViewController? {
        return self.delegateLock.sync { return self.delegate }
    }
    
    private func isPresenting(delegate: UIViewController) -> Bool {
        return ((delegate.presentedViewController as? RSTaskViewController) != nil) || self.isLaunching
    }
    
    public func setDelegate(delegate: UIViewController) -> Bool {
        return self.delegateLock.sync {
            if let oldDelegate = self.delegate,
                self.isPresenting(delegate: oldDelegate) {
                return false
            }
            else {
                self.delegate = delegate
                return true
            }
        }
    }
    
    public func newState(state: RSState) {
        
        if let delegate = self.getDelegate(),
            self.isPresenting(delegate: delegate) == false,
            let firstActivity = state.activityQueue.first,
            state.presentedActivity == nil,
            let activity = RSStateSelectors.activity(state, for: firstActivity.1),
            let task = taskForActivity(activity: activity, state: state) {
            
            let store = self.store
            let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { (taskViewController, reason, error) in
                
                //process on success action
                if reason == ORKTaskViewControllerFinishReason.completed {
                    let taskResult = taskViewController.result
                    self.processOnSuccessActions(activity: activity, taskResult: taskResult, store: store)
                }
                //process on failure actions
                else {
                    
                }
                
                //process finally actions
                self.delegate?.dismiss(animated: true, completion: {
                    let action = RSActionCreators.dismissedActivity(uuid: firstActivity.0, activityID: firstActivity.1)
                    store.dispatch(action)
                })
                
            }
            
            let taskViewController = RSTaskViewController(activityUUID: firstActivity.0, task: task, taskFinishedHandler: taskFinishedHandler)
            self.isLaunching = true
            delegate.present(taskViewController, animated: true, completion: { 
                self.isLaunching = false
                let action = RSActionCreators.presentedActivity(uuid: firstActivity.0, activityID: firstActivity.1)
                store.dispatch(action)
            })
        }
        
    }
    
    private func taskForActivity(activity: RSActivity, state: RSState) -> ORKTask? {
        
        let nodes = activity.elements.flatMap { (json) -> RSStepTreeNode? in
            return self.transformActivityElementIntoNode(
                jsonObject: json,
                stepTreeBuilder: self.stepTreeBuilder,
                state: state,
                identifierPrefix: activity.identifier
            )
        }
        
        let rootNode = RSStepTreeBranchNode(
            identifier: activity.identifier,
            identifierPrefix: "",
            type: "activity",
            children: nodes,
            navigationRules: nil,
            resultTransforms: nil
        )
        
        let stepTree = RSStepTree(identifier: activity.identifier, root: rootNode)
        
        debugPrint(stepTree)
        
        return stepTree
        
    }
    
    private func transformActivityElementIntoNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String) -> RSStepTreeNode? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for transformer in self.activityElementTransforms {
            if transformer.supportsType(type: type) {
                return transformer.generateNode(
                    jsonObject: jsonObject,
                    stepTreeBuilder: stepTreeBuilder,
                    state: state,
                    identifierPrefix: identifierPrefix
                )
            }
        }
        
        return nil
        
    }
    
    private func transformActivityElement(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for transformer in self.activityElementTransforms {
            if transformer.supportsType(type: type) {
                return transformer.generateSteps(jsonObject:jsonObject, taskBuilder:taskBuilder, state:state)
            }
        }
        
        return nil
        
    }
    
    private func processOnSuccessActions(activity: RSActivity, taskResult: ORKTaskResult, store: Store<RSState>) {
        
        let actionTransforms: [RSActionTransformer.Type] = [
            RSSendResultToServerActionTransformer.self,
            RSSetValueInStateActionTransformer.self,
            RSQueueActivityActionTransformer.self
        ]
        let onSuccessActionJSON: [JSON] = activity.onCompletion.onSuccessActions
        
        let context: [String: AnyObject] = ["taskResult": taskResult]
        
        onSuccessActionJSON.forEach { (actionJSON) in
            //check for predicate and evaluate
            //if predicate exists and evaluates false, do not execute action
            if let predicate: RSPredicate = "predicate" <~~ actionJSON,
                self.evaluatePredicate(predicate: predicate, state: store.state, context: context) == false {
                return
            }
            
            //if action malformed, do not execute action
            guard let type: String = "type" <~~ actionJSON else {
                return
            }
            
            for transformer in actionTransforms {
                if transformer.supportsType(type: type) {
                    guard let actionClosure = transformer.generateAction(jsonObject: actionJSON, context: context) else {
                        return
                    }
                    
                    store.dispatch(actionClosure)
                }
            }
            
        }
        
    }
    
    private func evaluatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> Bool {
        //construct substitution dictionary
        
        let nsPredicate = NSPredicate.init(format: predicate.format)
        
        guard let substitutionsJSON = predicate.substitutions else {
            return nsPredicate.evaluate(with: nil)
        }
        
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context),
                let value = valueConvertible.evaluate() as? NSObject {
                substitutions[key] = value
            }
            
        })
        
        guard substitutions.count == substitutionsJSON.count else {
            return false
        }
        
        return nsPredicate.evaluate(with: nil, substitutionVariables: substitutions)
        
    }
    

}
