//
//  RSPathTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/19/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSPathTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "path" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let path_type: String = "path_type" <~~ jsonObject else {
            return nil
        }
        
        if path_type == "parent",
            let layoutVC = context["layoutViewController"] as? RSLayoutViewController {
            
            let parentVC: RSLayoutViewController = layoutVC.parentLayoutViewController
            
            let parentPath: String = {
                if let nav = parentVC.viewController.navigationController as? RSNavigationController,
                    let parentPath = nav.getOriginalPath(for: parentVC) {
                    return parentPath
                }
                else {
                    return parentVC.matchedRoute.match.path
                }
            }()
            
            return RSValueConvertible(value: parentPath as NSString)
        }
        else if path_type == "back",
            let previousPath = RSStateSelectors.pathHistory(state).dropLast().last {
            
            return RSValueConvertible(value: previousPath as NSString)
            
        }
        else if path_type == "append",
            let layoutVC = context["layoutViewController"] as? RSLayoutViewController {
            
            if let append: String = "path" <~~ jsonObject {
                let path = layoutVC.matchedRoute.match.path + append
                return RSValueConvertible(value: path as NSString)
            }
            else if let appendJSON: JSON = "path" <~~ jsonObject,
                let append: String =  RSValueManager.processValue(jsonObject: appendJSON, state: state, context: context)?.evaluate() as? String {
                let path = layoutVC.matchedRoute.match.path + append
                return RSValueConvertible(value: path as NSString)
            }
            else {
                return nil
            }
            
            
        }
        
        else {
            return nil
        }
    }
    
}
