//
//  RSStandardNotification.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
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

open class RSStandardNotification: RSNotification {
    
    public let title: String
    public let body: String
    
    public let initialFire: JSON?
    public let repeating: JSON?
    public let monitoredValues: [JSON]
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let body: String = "body" <~~ json else {
                return nil
        }
        
        self.title = title
        self.body = body
        self.initialFire = "initialFire" <~~ json
        self.repeating = "repeat" <~~ json
        self.monitoredValues = "monitoredValues" <~~ json ?? []
        super.init(json: json)
    }
    
}
