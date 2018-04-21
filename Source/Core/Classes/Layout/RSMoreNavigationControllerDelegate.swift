//
//  RSMoreNavigationControllerDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
