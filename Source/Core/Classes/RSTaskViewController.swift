//
//  RSTaskViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit

open class RSTaskViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    var taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ())
    
    let activityUUID: UUID
    
    public var shouldConfirmCancelOverride: Bool? = nil
    
    public init(activityUUID: UUID, task: ORKTask, taskFinishedHandler: @escaping ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ())) {
        
        self.activityUUID = activityUUID
        self.taskFinishedHandler = taskFinishedHandler
        super.init(task: task, taskRun: nil)
        self.delegate = self
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        self.taskFinishedHandler(taskViewController, reason, error)
        
    }
    
    override open func stepViewControllerWillAppear(_ stepViewController: ORKStepViewController) {
        super.stepViewControllerWillAppear(stepViewController)
        if let task = self.task as? RSTask,
            task.shouldHideCancelButton {
            stepViewController.cancelButtonItem = nil
        }
    }
    
    open func taskViewControllerShouldConfirmCancel(_ taskViewController: ORKTaskViewController) -> Bool {
        
        if let shouldConfirmCancelOverride = self.shouldConfirmCancelOverride {
            return shouldConfirmCancelOverride
        }
        
        if let task = self.task as? RSTask {
            return task.shouldConfirmCancel
        }
        
        return true
    }
}
