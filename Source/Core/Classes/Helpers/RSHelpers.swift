//
//  RSHelpers.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss
import Mustache
import SwiftyMarkdown
import ResearchSuiteExtensions

public class RSHelpers {
    
    public static func getJSON(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String) -> JSON? {
        
        let urlPath: String = inDirectory != nil ? inDirectory! + "/" + fileName : fileName
        guard let url = URL(string: configJSONBaseURL + urlPath) else {
                return nil
        }
        
        return RSHelpers.getJSON(forURL: url)
    }
    
    public static func getJSON(forURL url: URL) -> JSON? {
        
        guard let fileContent = try? Data(contentsOf: url)
            else {
                assertionFailure("Unable to create NSData with content of file \(url)")
                return nil
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)) as? JSON else {
            return nil
        }
        
        return json
    }
    
    public static func getString(forURL url: URL) -> String? {
        
        //        print(url)
        guard let fileContent = try? Data(contentsOf: url)
            else {
                assertionFailure("Unable to create NSData with content of file \(url)")
                return nil
        }
        
        guard let s = String(data: fileContent, encoding: .utf8) else {
            return nil
        }
        
        return s
    }
    
    public static func writeJSON(json: JSON, toURL url: URL) -> Bool {
        
        if JSONSerialization.isValidJSONObject(json) {
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)) else {
                return false
            }
            
            do {
                try data.write(to: url, options: .atomicWrite)
                return true
            }
            catch {
                return false
            }
        }
        else {
            return false
        }
        
    }
    
    public static func delay(_ delay:TimeInterval, dispatchQueue: DispatchQueue = DispatchQueue.main,  closure:@escaping ()->()) {
        dispatchQueue.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    
    public static func registerFormatters(template: Template) {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        template.register(percentFormatter,  forKey: "percent")
        
        let timeInterval3Decimal = Filter { (timeInterval: TimeInterval?) in
            guard let timeInterval = timeInterval else {
                // No value, or not a TimeInterval: return nil.
                // We could throw an error as well.
                return nil
            }
            
            let timeIntervalFormatter = NumberFormatter()
            timeIntervalFormatter.numberStyle = .decimal
            timeIntervalFormatter.maximumFractionDigits = 3
            timeIntervalFormatter.minimumFractionDigits = 3
            
            guard let timeIntervalString = timeIntervalFormatter.string(for: timeInterval) else {
                return nil
            }
            
            // Return the result
            return "\(timeIntervalString) seconds"
        }
        
        template.register(timeInterval3Decimal,  forKey: "timeInterval3Decimal")
        
        let timeInterval2Decimal = Filter { (timeInterval: TimeInterval?) in
            guard let timeInterval = timeInterval else {
                // No value, or not a TimeInterval: return nil.
                // We could throw an error as well.
                return nil
            }
            
            let timeIntervalFormatter = NumberFormatter()
            timeIntervalFormatter.numberStyle = .decimal
            timeIntervalFormatter.maximumFractionDigits = 2
            timeIntervalFormatter.minimumFractionDigits = 2
            
            guard let timeIntervalString = timeIntervalFormatter.string(for: timeInterval) else {
                return nil
            }
            
            // Return the result
            return "\(timeIntervalString) seconds"
        }
        
        template.register(timeInterval2Decimal,  forKey: "timeInterval2Decimal")
        
    }
    
    public static func generateAttributedString(descriptor: RSTemplatedTextDescriptor, helper: RSTBTaskBuilderHelper, fontColor: UIColor? = nil, additionalContext: [String: AnyObject]? = nil) -> NSAttributedString? {
        
        let pairs: [(String, Any)] = descriptor.arguments.compactMap { (pair) -> (String, Any)? in
            guard let stateHelper = helper.stateHelper else {
                    return nil
            }
            
            let valueOpt: AnyObject? = {
                if let value: AnyObject = additionalContext?[pair.value] {
                    return value
                }
                else {
                    return stateHelper.valueInState(forKey: pair.value)
                }
            }()
            
            guard let value = valueOpt else {
                return nil
            }
            
            //Do we need to do localization here?
            if let stringValue = value as? String {
                return (pair.key, helper.localizationHelper.localizedString(stringValue))
            }
            else {
                return (pair.key, value)
            }
            
        }
        
        let arguments: [String: Any] = Dictionary.init(uniqueKeysWithValues: pairs)
        
        var renderedString: String?
        //check for mismatch in argument length
        guard descriptor.arguments.count == arguments.count else {
            return nil
        }
        
        //then pass through handlebars
        do {
            let template = try Template(string: helper.localizationHelper.localizedString(descriptor.template))
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
        
        if let color = fontColor {
            md.setFontColorForAllStyles(with: color)
        }
        
        let h1Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 35.0, weight: UIFont.Weight.light)
        
        md.h1.fontSize = h1Font.pointSize
        md.h1.fontName = h1Font.fontName
        
        let h2Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 32.0, weight: UIFont.Weight.light)
        
        md.h2.fontSize = h2Font.pointSize
        md.h2.fontName = h2Font.fontName
        
        let h3Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 28.0)
        
        md.h3.fontSize = h3Font.pointSize
        md.h3.fontName = h3Font.fontName
        
        let h4Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 24.0)
        
        md.h4.fontSize = h4Font.pointSize
        md.h4.fontName = h4Font.fontName
        
        let h5Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 20.0)
        
        md.h5.fontSize = h5Font.pointSize
        md.h5.fontName = h5Font.fontName
        
        let h6Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.subheadline, defaultSize: 15.0, typeAdjustment: 17.0)
        
        md.h6.fontSize = h6Font.pointSize
        md.h6.fontName = h6Font.fontName
        
        let bodyFont = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.body, defaultSize: 17.0, typeAdjustment: 14.0)
        
        md.body.fontSize = bodyFont.pointSize
        md.body.fontName = bodyFont.fontName
        
        
        let attributedString = NSMutableAttributedString(attributedString: md.attributedString())
        
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attributes, range, finish) in
            
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {
                return
            }
            
            let newFont = UIFont.systemFont(ofSize: font.pointSize)
            let newAttributes = attributes.merging([NSAttributedString.Key.font: newFont]) { (first, second) -> Any in
                second
            }
            attributedString.setAttributes(newAttributes, range: range)
            
        }
        
        return attributedString
    }
    
}
