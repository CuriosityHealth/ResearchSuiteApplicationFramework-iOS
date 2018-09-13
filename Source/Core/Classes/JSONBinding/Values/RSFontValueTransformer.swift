//
//  RSFontValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 9/13/18.
//

import UIKit
import Gloss

//fonts have the following fields:
// * size
// * name (if omitted, assume system font)
// * weight ( only if name omitted)
// * bold (only if name, weight omitted)
// * italic (only if name, weight omitted and bold false or omitted)
// * scaled (defaults to true)
//      Note that labels, etc need to also set the adjustsFontForContentSizeCategory property
//      See https://developer.apple.com/documentation/uikit/uifont/getting_a_scaled_font
public struct RSFont: Gloss.JSONDecodable {
    
    let size: CGFloat
    let name: String?
    let bold: Bool?
    let italic: Bool?
    let weight: CGFloat?
    let scaled: Bool
    
    public init?(json: JSON) {
        
        guard let size: CGFloat = "size" <~~ json else {
            return nil
        }
        
        self.size = size
        self.name = "name" <~~ json
        self.bold = "bold" <~~ json
        self.italic = "italic" <~~ json
        self.weight = "weight" <~~ json
        self.scaled = "scaled" <~~ json ?? true
        
    }
    
}

open class RSFontValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "font" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let rsFont: RSFont = "font" <~~ jsonObject,
            let font = self.convertFont(font: rsFont) else {
                return nil
        }

        return RSValueConvertible(value: font)
    }
    
    public static func convertFont(font: RSFont) -> UIFont? {
        
        //if name exists, try to create that
        if let fontName = font.name,
            let font = UIFont(name: fontName, size: font.size) {
            return font
        }
            
            //otherwise, check for weight
        else if let weight = font.weight {
            return UIFont.systemFont(ofSize: font.size, weight: UIFont.Weight(weight))
        }
            //otherwise, check for bold = true
        else if let bold = font.bold,
            bold == true {
            return UIFont.boldSystemFont(ofSize: font.size)
        }
            //otherwise, check for italic = true
        else if let italic = font.italic,
            italic == true {
            return UIFont.italicSystemFont(ofSize: font.size)
        }
        else {
            return UIFont.systemFont(ofSize: font.size)
        }
        
    }

}
