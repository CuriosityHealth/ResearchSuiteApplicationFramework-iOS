//
//  RSTitleLayoutGenerator.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import Gloss
import ReSwift

//open class RSTitleLayoutGenerator: RSLayoutGenerator {
//    
//    open func supportsType(type: String) -> Bool {
//        return type == "title"
//    }
//    open func generateLayout(jsonObject: JSON, store: Store<RSState>, layoutManager: RSLayoutManager) -> UIViewController? {
//        
//        guard let layout = RSTitleLayout(json: jsonObject) else {
//            return nil
//        }
//
//        let bundle = Bundle(for: RSTitleLayoutGenerator.self)
//        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
//
//        guard let titleLayoutVC = storyboard.instantiateViewController(withIdentifier: "titleLayoutViewController") as? RSLayoutTitleViewController else {
//            return nil
//        }
//
//        titleLayoutVC.titleLayout = layout
//        titleLayoutVC.store = store
//
//        return titleLayoutVC
//    }
//
//}
