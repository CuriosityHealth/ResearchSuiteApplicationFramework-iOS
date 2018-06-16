//
//  RSTemplatedMarkdownTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/5/18.
//

import UIKit
import Mustache
import Gloss
import SwiftyMarkdown
import ResearchSuiteExtensions
import ResearchSuiteTaskBuilder

open class RSTemplatedMarkdownDescriptor: Gloss.JSONDecodable {
    
    public let template: String
    public let arguments: [String: JSON]
    
    required public init?(json: JSON) {
        
        guard let template: String = "template" <~~ json else {
            return nil
        }
        
        self.template = template
        self.arguments = "arguments" <~~ json ?? [:]
        
    }
    
}

open class RSTemplatedMarkdownTransformer: RSValueTransformer {
    
//    class RSTBStateHelperAdaptor: NSObject, RSTBStateHelper {
//        
//        let state: RSState
//        init(state: RSState) {
//            self.state = state
//        }
//        
//        func valueInState(forKey: String) -> NSSecureCoding? {
//            return nil
//        }
//        
//        func setValueInState(value: NSSecureCoding?, forKey: String) {
//            
//        }
//        
//    }
    
    public func registerFormatters(template: Template) {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        
        template.register(percentFormatter,  forKey: "percent")
    }
    
    public static func supportsType(type: String) -> Bool {
        return "templatedMarkdown" == type
    }
    
    public static func registerFormatters(template: Template) {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        
        template.register(percentFormatter,  forKey: "percent")
    }
    
    public static func generateAttributedString(descriptor: RSTemplatedMarkdownDescriptor, state: RSState, context: [String: AnyObject]) -> NSAttributedString? {

        let argumentList:[(String, Any)] = descriptor.arguments.compactMap({ (pair) -> (String, Any)? in
            guard let value = RSValueManager.processValue(jsonObject: pair.value, state: state, context: context)?.evaluate() else {
                    return nil
            }
            
            return (pair.key, value)
        })
        
        let arguments: [String: Any] = Dictionary.init(uniqueKeysWithValues: argumentList)
        
        var renderedString: String?
        //check for mismatch in argument length
        guard descriptor.arguments.count == arguments.count else {
            return nil
        }
        
        //then pass through handlebars
        do {
            let template = try Template(string: descriptor.template)
            self.registerFormatters(template: template)
            renderedString = try template.render(arguments)
        }
        catch let error {
            return nil
        }
        
        guard let markdownString = renderedString else {
            return nil
        }
        
        //finally through markdown -> NSAttributedString
        //let's make Body the same as ORKLabel
        //let's adjust headers based on other labels too
        let md = SwiftyMarkdown(string: markdownString)
        //        md.h1.fontName = UIFont.preferredFont(forTextStyle: .title1).fontName
        
        let h1Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.headline, defaultSize: 17.0, typeAdjustment: 35.0, weight: UIFont.Weight.light)
        
        md.h1.fontSize = h1Font.pointSize
        md.h1.fontName = h1Font.fontName
        
        let h2Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.headline, defaultSize: 17.0, typeAdjustment: 32.0, weight: UIFont.Weight.light)
        
        md.h2.fontSize = h2Font.pointSize
        md.h2.fontName = h2Font.fontName
        
        let h3Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.headline, defaultSize: 17.0, typeAdjustment: 28.0)
        
        md.h3.fontSize = h3Font.pointSize
        md.h3.fontName = h3Font.fontName
        
        let h4Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.headline, defaultSize: 17.0, typeAdjustment: 24.0)
        
        md.h4.fontSize = h4Font.pointSize
        md.h4.fontName = h4Font.fontName
        
        let h5Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.headline, defaultSize: 17.0, typeAdjustment: 20.0)
        
        md.h5.fontSize = h5Font.pointSize
        md.h5.fontName = h5Font.fontName
        
        let h6Font = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.subheadline, defaultSize: 15.0, typeAdjustment: 17.0)
        
        md.h6.fontSize = h6Font.pointSize
        md.h6.fontName = h6Font.fontName
        
        let bodyFont = RSFonts.computeFont(startingTextStyle: UIFontTextStyle.body, defaultSize: 17.0, typeAdjustment: 14.0)
        
        md.body.fontSize = bodyFont.pointSize
        md.body.fontName = bodyFont.fontName
        
        
        let attributedString = md.attributedString()
        
        return attributedString
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let templateJSON: JSON = "markdownTemplate" <~~ jsonObject,
            let template = RSTemplatedMarkdownDescriptor(json: templateJSON) else {
                return nil
        }
    
        guard let attributedString = RSTemplatedMarkdownTransformer.generateAttributedString(descriptor: template, state: state, context: context) else {
            return nil
        }
        
//
//        var substitutions: [String: Any] = [:]
//
//        substitutionsJSON.forEach({ (key: String, value: JSON) in
//
//            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
//
//                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
//                //we also want to potentially have a null value substituted
//                if let value = valueConvertible.evaluate() {
//                    substitutions[key] = value
//                }
//                else {
//                    //                    assertionFailure("Added NSNull support for this type")
//                    let nilObject: AnyObject? = nil as AnyObject?
//                    substitutions[key] = nilObject as Any
//                }
//
//            }
//
//        })
//
//
//
//        do {
//
//            let template = try Template(string: template)
//            let renderedString = try template.render(substitutions)
//
//            return RSValueConvertible(value: renderedString as NSString)
//        }
//        catch let error {
//            debugPrint(error)
//            return nil
//        }

        return RSValueConvertible(value: attributedString as NSAttributedString)
    }
    
}
