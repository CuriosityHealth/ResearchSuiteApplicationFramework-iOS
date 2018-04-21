//
//  RSStateManagerProtocol.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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
