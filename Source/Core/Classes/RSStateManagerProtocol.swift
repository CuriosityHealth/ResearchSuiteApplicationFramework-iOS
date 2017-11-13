//
//  RSStateManagerProtocol.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import Gloss

public protocol RSStateManagerProtocol {
    func setValueInState(value: NSSecureCoding?, forKey: String)
    func valueInState(forKey: String) -> NSSecureCoding?
    func clearStateManager(completion: (Bool, Error?) -> ())
}
