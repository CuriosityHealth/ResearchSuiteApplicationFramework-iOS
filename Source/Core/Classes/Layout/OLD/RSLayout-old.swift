//
//  RSLayout-old.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/3/17.
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

//open class RSLayout: Gloss.JSONDecodable {
//
//    public let identifier: String
//    public let type: String
//    public let onLoadActions: [JSON]
//    public let navTitle: String?
//    public let navButtonRight: RSLayoutButton?
//    public let onBackActions: [JSON]
//    public let element: JSON
//    
//    required public init?(json: JSON) {
//        
//        guard let identifier: String = "identifier" <~~ json,
//            let type: String = "type" <~~ json else {
//                return nil
//        }
//        
//        self.identifier = identifier
//        self.type = type
//        self.onLoadActions = "onLoad" <~~ json ?? []
//        self.navTitle = "navTitle" <~~ json
//        self.navButtonRight = "navButtonRight" <~~ json
//        self.onBackActions = "onBack" <~~ json ?? []
//        self.element = json
//    }
//    
//}
