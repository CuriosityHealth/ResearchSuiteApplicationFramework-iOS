//
//  RSTabLayoutGenerator.swift
//  Pods
//
//  Created by James Kizer on 7/9/17.
//
//

import UIKit
import Gloss
import ReSwift

//open class RSTabLayoutGenerator: RSLayoutGenerator {
//    
//    open func supportsType(type: String) -> Bool {
//        return type == "tab"
//    }
//    open func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> UIViewController? {
//        
//        guard let layout = RSTabLayout(json: jsonObject) else {
//            return nil
//        }
//
//        let tabLayoutVC = RSLayoutTabBarViewController()
//        
//        tabLayoutVC.tabLayout = layout
//        tabLayoutVC.layoutManager = layoutManager
//        //note that viewDidLoad for RSLayoutTabBarViewController was getting invoked prior to returning
//        //from instantiation. We moved the subscribe call method to the store set listener
//        //We use layout and layoutManager in the newState method
//        //therefore, layout and layoutManager MUST be set prior to setting store
//        tabLayoutVC.store = store
//        
//        return tabLayoutVC
//    }
//
//}
