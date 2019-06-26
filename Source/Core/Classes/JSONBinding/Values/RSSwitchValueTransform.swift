//
//  RSSwitchValueTransform.swift
//  Pods
//
//  Created by James Kizer on 6/3/19.
//

import UIKit
import Gloss
import ReSwift

open class RSValueSwitchCase: Gloss.JSONDecodable {
    
    let predicate: RSPredicate?
    let value: JSON
    
    public required init?(json: JSON) {
        guard let value: JSON = "value" <~~ json else {
            return nil
        }
        
        self.predicate = "predicate" <~~ json
        self.value = value
    }
    
}

open class RSSwitchValueTransform: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "switch" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        guard let casesJSON: [JSON] = "cases" <~~ jsonObject else {
            return nil
        }
        
        let cases: [RSValueSwitchCase] = casesJSON.compactMap { RSValueSwitchCase(json: $0) }
        
        let evaluateSwitchCasePredicate: (RSValueSwitchCase) -> Bool = { switchCase in
            if let predicate = switchCase.predicate {
                return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: context)
            }
            else {
                return true
            }
        }
        
        guard let switchCase = cases.first(where: evaluateSwitchCasePredicate) else {
            return nil
        }
        
        return RSValueManager.processValue(jsonObject: switchCase.value, state: state, context: context)
    }
    

}
