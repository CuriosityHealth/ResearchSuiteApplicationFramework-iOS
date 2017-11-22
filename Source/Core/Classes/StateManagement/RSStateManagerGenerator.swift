//
//  RSStateManagerGenerator.swift
//  Pods
//
//  Created by James Kizer on 7/21/17.
//
//

import UIKit
import Gloss

public protocol RSStateManagerGenerator {
    static func supportsType(type: String) -> Bool
    static func generateStateManager(jsonObject: JSON) -> RSStateManagerProtocol?
}

