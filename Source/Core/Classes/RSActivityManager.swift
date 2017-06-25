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
    
    init(
        store: Store<RSState>,
        taskBuilder: RSTBTaskBuilder,
        activityElementTransforms: [RSActivityElementTransformer.Type] = RSActivityManager.defaultActivityElementTransforms
        ) {
        
        self.store = store
        self.delegateLock = DispatchQueue(label: "RSActivityManager.delegateLock")
        self.taskBuilder = taskBuilder
        self.activityElementTransforms = activityElementTransforms
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
        
        let steps = activity.elements.flatMap { (json) -> [ORKStep]? in
            return self.transformActivityElement(jsonObject: json, taskBuilder: self.taskBuilder, state: state)
        }.joined()
        let stepArray: [ORKStep] = Array(steps)
        
        let task = ORKOrderedTask(identifier: activity.identifier, steps: stepArray)
        
        return task
        
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
            RSSetValueInStateActionTransformer.self
        ]
        let onSuccessActionJSON: [JSON] = activity.onCompletion.onSuccessActions
        
        let context: [String: AnyObject] = ["taskResult": taskResult]
        
        onSuccessActionJSON.forEach { (actionJSON) in
            
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
    

}
