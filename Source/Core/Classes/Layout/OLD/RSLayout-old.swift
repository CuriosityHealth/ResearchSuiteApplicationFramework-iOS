//
//  RSLayout-old.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/3/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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
