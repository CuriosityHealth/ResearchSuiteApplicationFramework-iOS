//
//  RSResultTransform.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor
import Gloss

open class RSResultTransform: RSRPResultTransform {
    
    public let identifier: String
    
    public required init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        super.init(json: json)
        
    }

}
