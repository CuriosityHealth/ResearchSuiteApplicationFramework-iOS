//
//  RSStepTreeElementFileDescriptor.swift
//  Pods
//
//  Created by James Kizer on 8/15/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSStepTreeElementFileDescriptor: RSTBElementDescriptor {
    
    public let elementFilename: String?
    public let elementURLPath: String?
    public let elementURLBaseKey: String
    
    required public init?(json: JSON) {
        
        self.elementFilename = "elementFileName" <~~ json
        self.elementURLBaseKey = "elementURLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.elementURLPath = "elementURLPath" <~~ json
        
        super.init(json: json)
    }

}
