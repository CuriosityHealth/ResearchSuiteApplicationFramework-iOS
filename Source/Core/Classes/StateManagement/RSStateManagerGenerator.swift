//
//  RSStateManagerGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public protocol RSStateManagerGenerator {
    static func supportsType(type: String) -> Bool
    static func generateStateManager(jsonObject: JSON) -> RSStateManagerProtocol?
}

