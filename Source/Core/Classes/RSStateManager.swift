//
//  RSStateManager.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit

public protocol RSStateManager {
    
    func setValueInState(value: NSSecureCoding?, forKey: String)
    func valueInState(forKey: String) -> NSSecureCoding?
    
}
