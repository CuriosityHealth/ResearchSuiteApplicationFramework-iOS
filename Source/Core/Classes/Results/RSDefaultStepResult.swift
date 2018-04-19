//
//  RSDefaultStepResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/5/17.
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
import ResearchSuiteResultsProcessor
import Gloss

@objc open class RSDefaultStepResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    open class func type() -> String {
        return "default"
    }
    open class func supportedTypes() -> [String] {
        return [self.type()]
    }
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes().contains(type)
    }
    
    open class func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let stepResult = parameters["result"] as? ORKStepResult,
            let result = stepResult.firstResult else {
                return self.init(
                    type: self.type(),
                    uuid: UUID(),
                    taskIdentifier: taskIdentifier,
                    taskRunUUID: taskRunUUID,
                    result: nil
                )
        }
        
        return self.init(
            type: self.type(),
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            result: result
        )
    }
    
    let result: ORKResult?
    
    required public init?(
        type: String,
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        result: ORKResult?
        ) {
        
        self.result = result
        
        super.init(
            type: type,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
    
}
