//
//  RSMeasureManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public protocol RSMeasureGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(jsonObject: JSON, measureManager: RSMeasureManager, state: RSState) -> RSMeasure?
}

public class RSMeasureManager: NSObject {

    public static let DefaultMeasureGenerators: [RSMeasureGenerator.Type] = [
        RSMeasureFileGenerator.self
    ]
    
    private let measureGenerators: [RSMeasureGenerator.Type]
    private func generateDefaultMeasure(jsonObject: JSON) -> RSMeasure? {
        return RSMeasure(json: jsonObject)
    }
    
    public init(measureGenerators: [RSMeasureGenerator.Type] = RSMeasureManager.DefaultMeasureGenerators) {
        self.measureGenerators = measureGenerators
        super.init()
    }
    
    public func generate(jsonObject: JSON, state: RSState) -> RSMeasure? {
        
        if let type: String = "type" <~~ jsonObject {
            for generator in self.measureGenerators {
                if generator.supportsType(type: type),
                    let measure = generator.generate(jsonObject: jsonObject, measureManager: self, state: state) {
                    return measure
                }
            }
            
            return nil
        }
        else {
            return self.generateDefaultMeasure(jsonObject: jsonObject)
        }
    }
    

}
