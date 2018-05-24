//
//  RSStateObjectManager.swift
//  Pods
//
//  Created by James Kizer on 5/20/18.
//

import UIKit
import Gloss

public protocol RSStateObject: Glossy {
    static var stateObjectType: String { get }
//    static func supportsType(type: String) -> Bool
}

open class RSStateObjectManager: NSObject {
    
    let stateObjectTypeMap: [String: RSStateObject.Type]
    
    public init(stateObjectTypes: [RSStateObject.Type]) {
        let pairs: [(String, RSStateObject.Type)] = stateObjectTypes.map { ($0.stateObjectType, $0) }
        self.stateObjectTypeMap = Dictionary(uniqueKeysWithValues: pairs)
        super.init()
    }

}
