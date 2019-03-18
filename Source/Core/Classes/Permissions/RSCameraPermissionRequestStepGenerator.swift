//
//  RSCameraPermissionRequestStepGenerator.swift
//  Pods
//
//  Created by James Kizer on 2/18/19.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

open class RSCameraPermissionRequestStepGenerator: RSTBBaseStepGenerator {
    
    public init(){}
    
    open var supportedTypes: [String]! {
        return ["cameraPermissionRequest"]
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStep? {
        
        guard let stepDescriptor = RSCameraPermissionRequestStepDescriptor(json:jsonObject) else {
            return nil
        }
        
        let step = RSPermissionRequestStep(
            identifier: stepDescriptor.identifier,
            title: stepDescriptor.title,
            text: stepDescriptor.text,
            buttonText: stepDescriptor.buttonText,
            delegate: RSCameraPermissionRequestStepDelegate()
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
