//
//  RSFakeBackEnd.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor

public class RSFakeBackEnd: RSRPBackEnd {
    
    public init(){}
    
    public func add(intermediateResult: RSRPIntermediateResult) {
        
        debugPrint("we would be sending this result to the server!!!")
        debugPrint(intermediateResult)
        
    }
    
}
