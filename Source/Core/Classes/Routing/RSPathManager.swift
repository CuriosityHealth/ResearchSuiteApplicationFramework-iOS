//
//  RSPathManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift


public protocol RSPathGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(jsonObject: JSON, state: RSState) -> RSPath?
}

open class RSPathManager: NSObject {

    public let pathGenerators: [RSPathGenerator.Type]

    public init(
        pathGenerators: [RSPathGenerator.Type]?
        ) {
        self.pathGenerators = pathGenerators ?? []
        super.init()
    }

    open func generatePath(jsonObject: JSON, state: RSState) -> RSPath? {

        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }

        for pathGenerator in self.pathGenerators {
            if pathGenerator.supportsType(type: type),
                let path = pathGenerator.generate(jsonObject: jsonObject, state: state) {
                return path
            }
        }

        return nil
    }

}
