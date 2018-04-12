//
//  RSRootLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//

import UIKit
import Gloss

open class RSRootLayout: RSBaseLayout, RSLayoutGenerator {

    public static func supportsType(type: String) -> Bool {
        return type == "root"
    }
    
    public static func generate(jsonObject: JSON) -> RSLayout? {
        return RSRootLayout(json: jsonObject)
    }
    
}
