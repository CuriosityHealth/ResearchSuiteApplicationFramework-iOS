//
//  RSPathTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/19/18.
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

open class RSPathTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "path" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let value: String = "value" <~~ jsonObject else {
            return nil
        }
        
        if value == "parent",
            let layoutVC = context["layoutViewController"] as? RSLayoutViewController {
            let parentPath = layoutVC.parentLayoutViewController.matchedRoute.match.path
            return RSValueConvertible(value: parentPath as NSString)
        }
        else if value == "back",
            let previousPath = RSStateSelectors.pathHistory(state).dropLast().last {
            
            return RSValueConvertible(value: previousPath as NSString)
            
        }
        else {
            return nil
        }
    }
    
}
