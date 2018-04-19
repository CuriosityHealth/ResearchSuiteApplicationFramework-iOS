//
//  RSStepTreeConditionalNavigationRule.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
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

open class RSStepTreeConditionalNavigationRule: Gloss.JSONDecodable {
    
    let predicate: RSPredicate
    let destination: String
    
    public required init?(json: JSON) {
        guard let predicate: RSPredicate = "predicate" <~~ json,
            let destination: String = "destination" <~~ json else {
                return nil
        }
        
        self.predicate = predicate
        self.destination = destination
    }

}
