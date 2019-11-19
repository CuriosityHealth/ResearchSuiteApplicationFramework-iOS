//
//  RSNotificationPermissionsRequestStepGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
        
        let buttonText: String = helper.localizationHelper.localizedString(stepDescriptor.buttonText)
        
        let step = RSPermissionRequestStep(
            identifier: stepDescriptor.identifier,
            title: helper.localizationHelper.localizedString(stepDescriptor.title),
            text: helper.localizationHelper.localizedString(stepDescriptor.text),
            buttonText: buttonText,
            delegate: RSNotificationPermissionRequestStepDelegate()
        )
        
        step.isOptional = stepDescriptor.optional
        
        if let imageTitle = stepDescriptor.imageTitle,
            let image = UIImage(named: imageTitle) {
            step.image = image
        }
        
        return step
    }
    
    open func processStepResult(type: String,
                                jsonObject: JsonObject,
                                result: ORKStepResult,
                                helper: RSTBTaskBuilderHelper) -> JSON? {
        return nil
    }
    
}
