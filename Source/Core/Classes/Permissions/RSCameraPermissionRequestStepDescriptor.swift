//
//  RSCameraPermissionRequestStepDescriptor.swift
//  Pods
//
//  Created by James Kizer on 2/18/19.
//

import UIKit
import Gloss
import ResearchSuiteTaskBuilder

open class RSCameraPermissionRequestStepDescriptor: RSTBStepDescriptor {
    
    public let buttonText: String
    
    required public init?(json: JSON) {
        guard let buttonText: String = "buttonText" <~~ json else {
            return nil
        }
        self.buttonText = buttonText
        super.init(json: json)
    }
    
}
