//
//  RSMoreNavigationControllerDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//

import UIKit

open class RSMoreNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func dueToTap(vc: RSTabBarNavigationViewController) -> Bool {
        return true
    }
    
    let tabBarLayoutVC: RSTabBarLayoutViewController
    public init(tabBarLayoutVC: RSTabBarLayoutViewController) {
        self.tabBarLayoutVC = tabBarLayoutVC
        super.init()
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let layoutVC = viewController as? RSLayoutViewController {
            debugPrint(layoutVC.identifier)
        }
        else if let navController = viewController as? RSTabBarNavigationViewController {
            
            //if it was due to a tap, set the route to tab bar path
            //FOR NOW, assume that there is no harm done by always doing this
            if self.dueToTap(vc: navController) {
                let absolutePath = navController.getPath(incudeMore: false)
                let action = RSActionCreators.requestPathChange(path: absolutePath)
                self.tabBarLayoutVC.store?.dispatch(action)
            }
            
            debugPrint(navController)
        }
        else if let navController = viewController as? RSNavigationController {
            debugPrint(navController)
        }
        else {
            debugPrint(viewController)
            //set path to more
            let className = NSStringFromClass(type(of: viewController))
            //FOR NOW, assume that there is no harm done by always doing this
            if className == "UIMoreListController" {
                self.tabBarLayoutVC.redirectToMorePath()
            }
        }

        
    }

}
