//
//  RSPermissionRequestStep.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
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

open class RSPermissionRequestStep: ORKStep {
    
    let delegate: RSPermissionRequestStepDelegate
    let buttonText: String
    
    public init(identifier: String,
                title: String? = nil,
                text: String? = nil,
                buttonText: String? = nil,
                delegate: RSPermissionRequestStepDelegate) {
        
        let title = title ?? "Permissions"
        let text = text ?? "Please grant permissions"
        self.buttonText = buttonText ?? "Grant Permissions"
        self.delegate = delegate
        
        super.init(identifier: identifier)
        
        self.title = title
        self.text = text
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func stepViewControllerClass() -> AnyClass {
        return RSPermissionRequestStepViewController.self
    }
    
}
