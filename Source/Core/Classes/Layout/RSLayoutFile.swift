//
//  RSLayoutFile.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    
    private static func loadLayoutJSON(descriptor: RSLayoutFileDescriptor) -> JSON? {
        if let urlBase = RSApplicationDelegate.appDelegate.taskBuilderStateHelper.valueInState(forKey: descriptor.layoutURLBaseKey) as? String,
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
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        
        guard let descriptor: RSLayoutFileDescriptor = RSLayoutFileDescriptor(json: jsonObject),
            let json = RSLayoutFile.loadLayoutJSON(descriptor: descriptor) else {
            return nil
        }
        
        return layoutManager.generateLayout(jsonObject: json)
    }
    
    
    

}
