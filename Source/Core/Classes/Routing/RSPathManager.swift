//
//  RSPathManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
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
