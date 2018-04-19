//
//  RSLocationConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
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

open class RSLocationConfiguration: Gloss.JSONDecodable {
    
    //location config
    //by default, we do not monitor location changes
    //TODO: Add support for significant location changes
    //TODO: Add support for regular location changes
    //We do provide an action to request the current location
    //The config should provide a list of actions to execute when a new location is processed
    //RSSensedLocationValueTransform should support this
    public let predicate: RSPredicate
    public let onUpdate: RSPromise
    
    public required init?(json: JSON) {
        
        guard let onUpdate: RSPromise = "onUpdate" <~~ json,
            let predicate: RSPredicate = "predicate" <~~ json else {
            return nil
        }
        
        self.predicate = predicate
        self.onUpdate = onUpdate
    }

}
