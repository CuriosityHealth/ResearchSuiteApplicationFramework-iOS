//
//  RSTabLayoutGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/9/17.
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
import ReSwift

//open class RSTabLayoutGenerator: RSLayoutGenerator {
//    
//    open func supportsType(type: String) -> Bool {
//        return type == "tab"
//    }
//    open func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> UIViewController? {
//        
//        guard let layout = RSTabLayout(json: jsonObject) else {
//            return nil
//        }
//
//        let tabLayoutVC = RSLayoutTabBarViewController()
//        
//        tabLayoutVC.tabLayout = layout
//        tabLayoutVC.layoutManager = layoutManager
//        //note that viewDidLoad for RSLayoutTabBarViewController was getting invoked prior to returning
//        //from instantiation. We moved the subscribe call method to the store set listener
//        //We use layout and layoutManager in the newState method
//        //therefore, layout and layoutManager MUST be set prior to setting store
//        tabLayoutVC.store = store
//        
//        return tabLayoutVC
//    }
//
//}
