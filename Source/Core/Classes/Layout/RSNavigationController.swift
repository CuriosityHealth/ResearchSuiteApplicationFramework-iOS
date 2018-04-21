//
//  RSNavigationController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

open class RSNavigationController: UINavigationController, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    private var popRequestQueue: DispatchQueue!
    private var popRequests: Set<String>!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = delegate
        self.popRequests = Set<String>()
        self.popRequestQueue = DispatchQueue(label: "PopRequestQueue")
    }
    
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void)
    {
        self.pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) {
            _ in completion()
        }

    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        
        //dont do anything
        
        return nil
        
    }
    
    public func popViewController(layoutVC: RSLayoutViewController,
                                  animated: Bool,
                                  completion: @escaping (UIViewController?) -> Void) {
        
        
        guard let lvc = self.visibleViewController as? RSLayoutViewController else{
            completion(nil)
            return
        }
        
        assert(layoutVC.viewController == self.visibleViewController)
        
        let parent:RSLayoutViewController = lvc.parentLayoutViewController
        self.popRequestQueue.async {
            self.popRequests = self.popRequests.union([parent.identifier])
        }
        
        let viewController = super.popViewController(animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion(viewController)
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion(viewController)
        }

    }
    
    public func navigationBar(_ navigationBar: UINavigationBar,
                              shouldPop item: UINavigationItem) -> Bool {
        
        //during a reroute request, the parent will be the visible view controller
        //in the case of back being touched, this will be the actual vc
        if let lvc = self.visibleViewController as? RSLayoutViewController {
            let requested: Bool = self.popRequestQueue.sync {
                let r = self.popRequests.contains(lvc.identifier)
                if r {
                    self.popRequests = self.popRequests.subtracting([lvc.identifier])
                }
                return r
            }
            
            if requested {
                return true
            }
            else {
                lvc.backTapped()
                return false
            }
        }
            
        else {
            //            assertionFailure()
            return true
        }
        
    }

}
