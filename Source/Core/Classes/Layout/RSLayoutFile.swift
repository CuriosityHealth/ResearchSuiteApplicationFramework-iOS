//
//  RSLayoutFile.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSLayoutFileDescriptor {
    
    public let layoutFilename: String?
    public let layoutURLPath: String?
    public let layoutURLBaseKey: String
    
    required public init?(json: JSON) {
        
        self.layoutFilename = "layoutFilename" <~~ json
        self.layoutURLBaseKey = "layoutURLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.layoutURLPath = "layoutURLPath" <~~ json
        
    }
    
}

open class RSLayoutFile: RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "layoutFile"
    }
    
    private static func loadLayoutJSON(descriptor: RSLayoutFileDescriptor, state: RSState) -> JSON? {
        if let urlBase = RSStateSelectors.getValueInCombinedState(state, for: descriptor.layoutURLBaseKey) as? String,
            let urlPath = descriptor.layoutURLPath,
            let url = URL(string: urlBase + urlPath) {

            return RSHelpers.getJSON(forURL: url)
            
        }
        else if let filename = descriptor.layoutFilename {
            return RSHelpers.getJson(forFilename: filename) as? JSON
        }
        else {
            return nil
        }
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        
        guard let descriptor: RSLayoutFileDescriptor = RSLayoutFileDescriptor(json: jsonObject),
            let json = RSLayoutFile.loadLayoutJSON(descriptor: descriptor, state: state) else {
            return nil
        }
        
        return layoutManager.generateLayout(jsonObject: json, state: state)
    }
    
    
    

}
