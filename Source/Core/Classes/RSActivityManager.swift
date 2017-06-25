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
    
    let activityElementTransforms: [RSActivityElementTransformer.Type] = [
        RSMeasureActivityElementTransformer.self,
        RSInstructionActivityElementTransformer.self
    ]
    
    let taskBuilder: RSTBTaskBuilder
    
    init(store: Store<RSState>, taskBuilder: RSTBTaskBuilder) {
        
        self.store = store
        self.delegateLock = DispatchQueue(label: "RSActivityManager.delegateLock")
        self.taskBuilder = taskBuilder
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
            let task = taskForActivity(activityID: firstActivity.1, state: state) {
            
            let store = self.store
            let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { (taskViewController, reason, error) in
                
                //process on success action
                if reason == ORKTaskViewControllerFinishReason.completed {
                    
                }
                //process on failure actions
                else {
                    
                }
                
                //process finally actions
                self.delegate?.dismiss(animated: true, completion: nil)
                
            }
            
            let taskViewController = RSTaskViewController(activityUUID: firstActivity.0, task: task, taskFinishedHandler: taskFinishedHandler)
            self.isLaunching = true
            delegate.present(taskViewController, animated: true, completion: { 
                self.isLaunching = false
            })
        }
        
    }
    
    private func taskForActivity(activityID: String, state: RSState) -> ORKTask? {
        
        guard let activity = RSStateSelectors.activity(state, for: activityID) else {
            return nil
        }
        
        let steps = activity.elements.flatMap { (json) -> [ORKStep]? in
            return self.transformActivityElement(jsonObject: json, taskBuilder: self.taskBuilder, state: state)
        }.joined()
        let stepArray: [ORKStep] = Array(steps)
        
        let task = ORKOrderedTask(identifier: activityID, steps: stepArray)
        
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
    

}
