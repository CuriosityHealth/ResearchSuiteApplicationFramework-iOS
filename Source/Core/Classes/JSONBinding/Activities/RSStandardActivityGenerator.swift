//
//  RSStandardActivityGenerator.swift
//  Pods
//
//  Created by James Kizer on 6/4/18.
//

import UIKit
import Gloss

open class RSStandardActivityGenerator: RSActivityGenerator {

    public static func supportsType(type: String?) -> Bool {
        return true
    }
    
    public static func generate(jsonObject: JSON, activityManager: RSActivityManager) -> RSActivity? {
        return RSActivity(json: jsonObject)
    }
    
}
