//
//  RSColorAssetValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 8/30/18.
//

//import UIKit
//import Gloss
//
//open class RSColorAssetValueTransformer: RSValueTransformer {
//    
//    public static func supportsType(type: String) -> Bool {
//        return "colorAsset" == type
//    }
//    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
//        guard let identifier: String = "identifier" <~~ jsonObject,
//            let color = UIColor(named: identifier) else {
//            return nil
//        }
//        
//        return RSValueConvertible(value: color)
//    }
//    
//}
