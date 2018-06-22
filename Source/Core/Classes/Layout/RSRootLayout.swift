//
//  RSRootLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSRootLayout: RSBaseLayout, RSLayoutGenerator {

    public static func supportsType(type: String) -> Bool {
        return type == "root"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSRootLayout(json: jsonObject)
    }
    
}
