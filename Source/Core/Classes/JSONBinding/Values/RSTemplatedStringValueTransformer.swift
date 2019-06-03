//
//  RSTemplatedStringValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/6/18.
//

import UIKit
import Mustache
import Gloss

open class RSTemplatedStringValueTransformer: RSValueTransformer {
    
    public static func humanReadibleListOfString(strings: [String]) -> String {
        switch strings.count {
        case 0:
            return ""
        case 1:
            return strings[0]
        case 2:
            return "\(strings[0]) and \(strings[1])"
        default:
            return strings.enumerated().reduce("", { (acc, pair) -> String in
                
                //                    if last, don't append
                //if second to last, append ", and "
                //else, append ", "
                if pair.offset == strings.count - 1 {
                    return acc + pair.element
                }
                else if pair.offset == strings.count - 2 {
                    return acc + pair.element + ", and "
                }
                else {
                    return acc + pair.element + ", "
                }
                
            })
        }
    }
    
    public static func registerFormatters(template: Template) {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        
        template.register(percentFormatter,  forKey: "percent")
        
        let mapSelect = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let array = boxes[0].arrayValue,
                let selectKey = boxes[1].value as? String else {
                    return nil
            }
            
            let returnArray = array.compactMap { $0.mustacheBox(forKey: selectKey) }
            
            return returnArray
        }
        
        //this will take an array, path, and value
        //will find first element that where value at path matches key and returns it
        //helpful when we want to access a single element in an array by an identifier
        let selectElement = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let array = boxes[0].arrayValue,
                let selectPath = boxes[1].value as? String,
                let selectValue = boxes[2].value as? NSObject else {
                    return nil
            }
            
            let element = array.first(where: { (box) -> Bool in
                guard let selectedBoxValue = box.mustacheBox(forKey: selectPath).value as? NSObject else {
                    return false
                }
                //                print(selectedBoxValue)
                return selectedBoxValue.isEqual(selectValue)
            })
            
            return element
        }
        
        let contains = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let array = boxes[0].arrayValue,
                let matchingValue = boxes[1].value else {
                    return false
            }
            
            let mappedValues: [AnyObject] = array.compactMap({ $0.value as AnyObject })
            
            return mappedValues.contains(where: { $0.isEqual(matchingValue) })
        }
        
        let jsonString = Filter { (dict: JSON?) -> Any? in
            guard let jsonValue = dict,
                JSONSerialization.isValidJSONObject(jsonValue),
                let jsonData = try? JSONSerialization.data(withJSONObject: jsonValue, options: [.prettyPrinted]),
                let jsonString = String(data: jsonData, encoding: .utf8) else {
                    return nil
            }
            
            return jsonString
        }
        
        let some = Filter { (box: MustacheBox) -> Any? in
            if box.isEmpty {
                return false
            }
            
            if let dictionary = box.dictionaryValue {
                return dictionary.count > 0
            }
            else if let array = box.arrayValue {
                return array.count > 0
            }
            else {
                return false
            }
        }
        
        let listOfStrings = Filter { (box: MustacheBox) -> Any? in
            
            guard let array = box.arrayValue else {
                return nil
            }
            
            let localizationHelper = RSApplicationDelegate.appDelegate.localizationHelper
            
            let strings: [String] = array
                .compactMap({ $0.value as? String })
                .map { localizationHelper.localizedString($0) }
            
            return self.humanReadibleListOfString(strings: strings)
            
        }
        
        let halfOpenRange = VariadicFilter { (boxes: [MustacheBox]) in
            
            guard let start = boxes[0].value as? Int,
                let end = boxes[1].value as? Int else {
                    return nil
            }
            
            return start..<end
        }
        
        template.register(mapSelect, forKey: "mapSelect")
        template.register(contains, forKey: "contains")
        template.register(selectElement, forKey: "select")
        template.register(jsonString, forKey: "jsonString")
        template.register(some, forKey: "some")
        template.register(StandardLibrary.each, forKey: "each")
        template.register(listOfStrings, forKey: "listOfStrings")
//        template.register(escapeControlCharacters, forKey: "escapeControlCharacters")
        template.register(halfOpenRange, forKey: "range")
    }
    
    public static func supportsType(type: String) -> Bool {
        return "templatedString" == type
    }
    
    public static func generateString(templatedString: String, substitutions: [String: Any]) throws -> String {
        let template = try Template(string: templatedString)
        self.registerFormatters(template: template)
        return try template.render(substitutions)
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        let localizationHelper = RSApplicationDelegate.appDelegate.localizationHelper
        guard let template: String = localizationHelper.localizedString("template" <~~ jsonObject),
            let substitutionsJSON: [String: JSON] = "substitutions" <~~ jsonObject else {
            return nil
        }
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
                
                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
                //we also want to potentially have a null value substituted
                if let value = valueConvertible.evaluate() {
                    
                    if let str = value as? String {
                        substitutions[key] = localizationHelper.localizedString(str)
                    }
                    else if let listOfStr = value as? [String] {
                        substitutions[key] = listOfStr.map({ localizationHelper.localizedString($0) })
                    }
                    else {
                        substitutions[key] = value
                    }
                    
                }
                else {
                    //                    assertionFailure("Added NSNull support for this type")
                    let nilObject: AnyObject? = nil as AnyObject?
                    substitutions[key] = nilObject as Any
                }
                
            }
            
        })
        
        
        
        do {
            let renderedString = try self.generateString(templatedString: template, substitutions: substitutions)
            return RSValueConvertible(value: renderedString as NSString)
        }
        catch let error {
//            debugPrint(error)
            return nil
        }
        
    }

}
