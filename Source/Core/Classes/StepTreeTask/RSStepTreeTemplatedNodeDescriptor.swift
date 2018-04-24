//
//  RSStepTreeTemplatedNodeDescriptor.swift
//  Pods
//
//  Created by James Kizer on 4/22/18.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSStepTreeTemplatedNodeDescriptor: RSTBElementDescriptor {
    
    public let templateFilename: String?
    public let templateURLPath: String?
    public let templateURLBaseKey: String
    public let parameters: JSON?
    
    required public init?(json: JSON) {
        
        self.templateFilename = "templateFileName" <~~ json
        self.templateURLBaseKey = "templateURLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.templateURLPath = "templateURLPath" <~~ json
        self.parameters = "parameters" <~~ json
        
        super.init(json: json)
    }
    
}
