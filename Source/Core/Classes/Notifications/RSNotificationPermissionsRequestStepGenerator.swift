//
//  RSNotificationPermissionsRequestStepGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

open class RSNotificationPermissionsRequestStepGenerator: RSTBBaseStepGenerator {
    
    public init(){}
    
    open var supportedTypes: [String]! {
        return ["notificationPermissionRequest"]
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStep? {
        
        guard let stepDescriptor = RSNotificationPermissionRequestStepDescriptor(json:jsonObject) else {
            return nil
        }
        
        let step = RSPermissionRequestStep(
            identifier: stepDescriptor.identifier,
            title: stepDescriptor.title,
            text: stepDescriptor.text,
            buttonText: stepDescriptor.buttonText,
            delegate: RSNotificationPermissionRequestStepDelegate()
        )
        
        step.isOptional = stepDescriptor.optional
        
        return step
    }
    
    open func processStepResult(type: String,
                                jsonObject: JsonObject,
                                result: ORKStepResult,
                                helper: RSTBTaskBuilderHelper) -> JSON? {
        return nil
    }
    
}
