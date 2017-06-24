//
//  ValueConvertible.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit

public protocol ValueConvertible {
    var valueConvertibleType: String { get }
    func evaluate() -> AnyObject?
}
