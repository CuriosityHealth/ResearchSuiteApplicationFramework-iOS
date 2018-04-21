//
//  RSMoreNavigationControllerDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

open class RSMoreNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func dueToTap(vc: RSTabBarNavigationViewController) -> Bool {
        return self.listWasLast
    }
    
    let tabBarLayoutVC: RSTabBarLayoutViewController
    var listWasLast: Bool = false
    public init(tabBarLayoutVC: RSTabBarLayoutViewController) {
        self.tabBarLayoutVC = tabBarLayoutVC
        super.init()
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let listWasLast = self.listWasLast
        self.listWasLast = false
        if let navController = viewController as? RSTabBarNavigationViewController {
            
            //if it was due to a tap, set the route to tab bar path
            //FOR NOW, assume that there is no harm done by always doing this
            if listWasLast {
                let absolutePath = navController.getPath(incudeMore: false)
                let action = RSActionCreators.requestPathChange(path: absolutePath)
                self.tabBarLayoutVC.store?.dispatch(action)
            }
            
        }
        else {
            //set path to more
            let className = NSStringFromClass(type(of: viewController))
            //FOR NOW, assume that there is no harm done by always doing this
            if className == "UIMoreListController" {
                self.listWasLast = true
                self.tabBarLayoutVC.redirectToMorePath()
            }
        }

        
    }

}
