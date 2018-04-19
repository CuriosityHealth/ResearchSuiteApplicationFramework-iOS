//
//  RSStateManagerProtocol.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
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

public protocol RSStateManagerProtocol {
    var identifier: String { get }
    //isEphemeral tells the framework whether this state manager is intended to be ephemeral
    //if true, the stateValueHasBeenSet metadata is not persisted across applicaiton launches
    var isEphemeral: Bool { get }
    func setValueInState(value: NSSecureCoding?, forKey: String)
    func valueInState(forKey: String) -> NSSecureCoding?
    func clearStateManager(completion: @escaping (Bool, Error?) -> ())
}
