//
//  RSValueManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss
import LS2SDK

public struct RSValueLog: JSONEncodable {
    
    
    let value: JSON
    let uuid: UUID
    let timestamp: Date
    var evaluated: AnyObject?
//    var malformedAction = false
//    var predicateResult: Bool? = nil
//    var successfulTransforms: [String] = []
    
    
    public static func encode(key: String) -> ((AnyObject?) -> JSON?) {
        return { value in
            if let date = value as? Date {
                return Gloss.Encoder.encode(dateISO8601ForKey: key)(date)
            }
            else if let dateComponents = value as? DateComponents {
                
                let dateFormatter = DateComponentsFormatter()
                dateFormatter.allowedUnits = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfMonth ,NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
                
                if let dateComponentsString = dateFormatter.string(from: dateComponents) {
                    return key ~~> dateComponentsString
                }
                else {
                    assertionFailure("cannot handle key: \(key), value: \(value)")
                    return nil
                }
                
            }
            else if let color = value as? UIColor {
                return key ~~> color.hexString
            }
            else if let convertible = value as? LS2DatapointConvertible,
                let datapoint = convertible.toDatapoint(builder: LS2ConcreteDatapoint.self) {
                return key ~~> datapoint.toJSON()
            }
            else if let attributedString = value as? NSAttributedString {
                return key ~~> attributedString.string
            }
            else if let json = key ~~> value {
                return json
            }
            else if value != nil{
                assertionFailure("cannot handle key: \(key), value: \(value)")
                return nil
            }
            else {
                return nil
            }
        }
    }
    
    public func toJSON() -> JSON? {
        
        return jsonify([
            "value" ~~> self.value,
            "uuid" ~~> self.uuid,
            Gloss.Encoder.encode(dateISO8601ForKey: "timestamp")(self.timestamp),
            RSValueLog.encode(key: "evaluated")(self.evaluated)
            ])
    }
    
    public init(value: JSON) {
        self.value = value
        self.uuid = UUID()
        self.timestamp = Date()
    }
    
}

public protocol RSValueManagerDelegate: class {
    func log(log: RSValueLog)
}


open class RSValueManager: NSObject {
    
    //TODO: add state value transformer
//    public static let valueTransformers: [RSValueTransformer.Type] = [
//        RSResultTransformValueTransformer.self,
//        RSConstantValueTransformer.self,
//        RSFunctionValueTransformer.self,
//        RSStepTreeResultTransformValueTransformer.self,
//        RSStateValueTransformer.self,
//        RSSpecialValueTransformer.self,
//        RSLiteralValueTransformer.self,
//        RSDateComponentsTransform.self
//    ]
    
    
    public weak var delegate: RSValueManagerDelegate?
    
    let  valueTransforms: [RSValueTransformer.Type]
    
    public init(
        valueTransforms: [RSValueTransformer.Type]?
        ) {
        self.valueTransforms = valueTransforms ?? []
        super.init()
    }
    
    //generate values
    //TODO: make distinction between truly nil values and programming / config errors
    //right now, we just return nil, which is ambiguous
    public func processValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        var log = RSValueLog(value: jsonObject)
        
        defer {
            self.delegate?.log(log: log)
        }
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        let transforms = self.valueTransforms
        
        for transformer in transforms {
            if transformer.supportsType(type: type),
                let value = transformer.generateValue(jsonObject: jsonObject, state: state, context: context) {
                
                log.evaluated = value.evaluate()
                
                return value
                
            }
        }
        
        return nil
    
    }
    
    public static func processValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        return RSApplicationDelegate.appDelegate.valueManager.processValue(
            jsonObject: jsonObject,
            state: state,
            context: context
        )
        
    }
    
    public static func valueChanged(jsonObject: JSON, state: RSState, lastState: RSState, context: [String: AnyObject]) -> Bool {
        guard let currentValueConvertible = RSValueManager.processValue(jsonObject: jsonObject, state: state, context: context),
            let lastValueConvertible = RSValueManager.processValue(jsonObject: jsonObject, state: lastState, context: context) else {
                return false
        }
        
        let currentValue = currentValueConvertible.evaluate()
        let lastValue = lastValueConvertible.evaluate()
        
        if currentValue == nil && lastValue == nil {
            return false
        }
        
        //we checked above to see if both are nil,
        //therefore if one is, the other isnt
        if currentValue == nil || lastValue == nil {
            return true
        }
        
        guard let c = currentValue as? NSObject,
            let l = lastValue as? NSObject else {
                assertionFailure("Assuming that all objects inherit from NSObject")
                return false
        }
        
        //otherwise, we know that both are not nil
        return c != l
    }

}
