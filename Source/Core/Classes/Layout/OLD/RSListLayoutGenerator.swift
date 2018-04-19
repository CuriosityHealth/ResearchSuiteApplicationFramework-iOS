//
//  RSListLayoutGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/4/17.
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

//open class RSListLayoutGenerator: RSLayoutGenerator {
//    
//    open func supportsType(type: String) -> Bool {
//        return type == "list"
//    }
//    open func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> UIViewController? {
//        
//        guard let layout = RSListLayout(json: jsonObject) else {
//            return nil
//        }
//        
//        let bundle = Bundle(for: RSListLayoutGenerator.self)
//        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
//        
//        guard let listLayoutVC = storyboard.instantiateViewController(withIdentifier: "listLayoutViewController") as? RSLayoutTableViewController else {
//            return nil
//        }
//        
//        listLayoutVC.listLayout = layout
//        listLayoutVC.store = store
//        
//        return listLayoutVC
//    }
//
//}
