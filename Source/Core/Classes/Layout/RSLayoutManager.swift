//
//  RSLayoutManager.swift
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

public protocol RSLayoutGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout?
}

public class RSLayoutManager: NSObject {
    
    let layoutGenerators: [RSLayoutGenerator.Type]
    
    public init(
        layoutGenerators: [RSLayoutGenerator.Type]?
        ) {
        self.layoutGenerators = layoutGenerators ?? []
        super.init()
    }
    
    public func generateLayout(jsonObject: JSON) -> RSLayout? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for layoutGenerator in layoutGenerators {
            if layoutGenerator.supportsType(type: type),
                let layout = layoutGenerator.generate(jsonObject: jsonObject, layoutManager: self) {
                return layout
            }
        }
        return nil
    }
}

