//
//  RSListLayoutGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/4/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

//open class RSListLayoutGenerator: RSLayoutGenerator {
//    
//    open func supportsType(type: String) -> Bool {
//        return type == "list"
//    }
//    open func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> UIViewController? {
//        
//        guard let layout = RSListLayout(json: jsonObject) else {
//            return nil
//        }
//        
//        let bundle = Bundle(for: RSListLayoutGenerator.self)
//        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
//        
//        guard let listLayoutVC = storyboard.instantiateViewController(withIdentifier: "listLayoutViewController") as? RSLayoutTableViewController else {
//            return nil
//        }
//        
//        listLayoutVC.listLayout = layout
//        listLayoutVC.store = store
//        
//        return listLayoutVC
//    }
//
//}
