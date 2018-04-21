//
//  RSE+RSRPDefaultValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/11/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import ResearchSuiteExtensions
import ResearchSuiteResultsProcessor

extension RSEnahncedMultipleChoiceSelection {
    func toDictionary() -> NSDictionary {
        
        if let auxResult = self.auxiliaryResult as? RSRPDefaultValueTransformer {
            let dictionary = [
                "value": self.value,
                "auxValue": auxResult.defaultValue
            ]
            return dictionary as NSDictionary
        }
        else {
            let dictionary = [
                "value": self.value
            ]
            return dictionary as NSDictionary
        }
        
    }
}

extension RSEnhancedMultipleChoiceResult: RSRPDefaultValueTransformer {
    public var defaultValue: AnyObject? {
        if let answers = self.choiceAnswers {
            let dictAnswers = answers.map { $0.toDictionary() }
            return dictAnswers as NSArray
        }
        return nil
    }
}
