//
//  RSLayoutGenerator.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

import UIKit
import Gloss
import ReSwift

public protocol RSLayoutGenerator {
    
    static func supportsType(type: String) -> Bool
    static func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> ValueConvertible?

}
