//
//  RSPermissionRequestStep.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteExtensions

open class RSPermissionRequestStep: RSStep {
    
    let delegate: RSPermissionRequestStepDelegate
    open var image: UIImage?
    
    public init(identifier: String,
                title: String? = nil,
                text: String? = nil,
                buttonText: String? = nil,
                image: UIImage? = nil,
                delegate: RSPermissionRequestStepDelegate) {
        
        let title = title ?? "Permissions"
        let text = text ?? "Please grant permissions"
        self.delegate = delegate
        
        super.init(identifier: identifier)
        
        self.title = title
        self.text = text
        self.buttonText = buttonText ?? "Grant Permissions"
        self.image = image
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func stepViewControllerClass() -> AnyClass {
        return RSPermissionRequestStepViewController.self
    }
    
}
