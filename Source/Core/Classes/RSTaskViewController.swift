//
//  RSTaskViewController.swift
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
import ResearchKit

open class RSTaskViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    var taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ())
    
    let activityUUID: UUID
    
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
}
