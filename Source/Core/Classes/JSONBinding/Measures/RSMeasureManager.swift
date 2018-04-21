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

public class RSMeasureManager: NSObject {
    
    private let measureMap: [String: RSMeasure]
    init?(measureFileName: String) {
        
        guard let json = RSHelpers.getJson(forFilename: measureFileName) as? JSON,
            let measures: [RSMeasure] = "measures" <~~ json else {
                return nil
        }
        
        var measureMap: [String: RSMeasure] = [:]
        measures.forEach { (measure) in
            measureMap[measure.identifier] = measure
        }
        
        self.measureMap = measureMap
        
    }
    
    public func measure(for identifier: String) -> RSMeasure? {
        return self.measureMap[identifier]
    }

}
