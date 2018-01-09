//
//  RSLocationPermissionRequestStepDescriptor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/8/18.
//

import UIKit
import Gloss
import ResearchSuiteTaskBuilder

open class RSLocationPermissionRequestStepDescriptor: RSTBStepDescriptor {
    
    public let buttonText: String
    
    required public init?(json: JSON) {
        guard let buttonText: String = "buttonText" <~~ json else {
            return nil
        }
        self.buttonText = buttonText
        super.init(json: json)
    }

}
