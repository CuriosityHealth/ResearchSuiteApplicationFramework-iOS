//
//  RSNotificationPermissionRequestStepDescriptor.swift
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

open class RSNotificationPermissionRequestStepDescriptor: RSTBStepDescriptor {
    
    public let buttonText: String
    public let skipButtonText: String?
    public let skipButtonHasBorder: Bool
    public let imageTitle: String?
    
    required public init?(json: JSON) {
        guard let buttonText: String = "buttonText" <~~ json else {
            return nil
        }
        self.buttonText = buttonText
        self.skipButtonText = "skipButtonText" <~~ json
        self.skipButtonHasBorder = "skipButtonHasBorder" <~~ json ?? false
        self.imageTitle = "imageTitle" <~~ json
        super.init(json: json)
    }
    
}
