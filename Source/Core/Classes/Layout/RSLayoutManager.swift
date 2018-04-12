//
//  RSLayoutManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//

import UIKit
import Gloss

public protocol RSLayoutGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(jsonObject: JSON) -> RSLayout?
}

public class RSLayoutManager: NSObject {
    
    let layoutGenerators: [RSLayoutGenerator.Type]
    
    public init(
        layoutGenerators: [RSLayoutGenerator.Type]?
        ) {
        self.layoutGenerators = layoutGenerators ?? []
        super.init()
    }
    
    public func generateLayout(jsonObject: JSON) -> RSLayout? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for layoutGenerator in layoutGenerators {
            if layoutGenerator.supportsType(type: type),
                let layout = layoutGenerator.generate(jsonObject: jsonObject) {
                return layout
            }
        }
        return nil
    }
}

