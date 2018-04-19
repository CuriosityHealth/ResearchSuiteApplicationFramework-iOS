//
//  RSRootLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
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

//open class RSRootLayoutViewController: UIViewController, RSLayoutViewController {
//    
//    private var rootViewController: UIViewController! = nil
//    
//    open var layout: RSLayout!
//    
//    //MARK: RSLayoutViewController Methods
//    public func layoutDidLoad() {
//        
//    }
//    
//    public func backTapped() {
//        assertionFailure("NOT IMPLEMENTED!!")
//    }
//    
//    
//    public var identifier: String! {
//        return "ROOT!!"
//    }
//    
//    //    public var layout: RSLayout! {
//    //        return nil
//    //    }
//    
//    public var matchedRoute: RSMatchedRoute! {
//        return nil
//    }
//    
//    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
//        
//    }
//    
//    public var parentLayoutViewController: RSLayoutViewController!
//    
//    public var viewController: UIViewController! {
//        return self
//    }
//    
//    private var childLayoutVCs: [RSLayoutViewController] = []
//    
//    private func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
//        
//        return childLayoutVCs.first(where: { (lvc) -> Bool in
//            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
//        })
//        
//    }
//    
//    private func transition(to newViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
//        if animated {
//            self.animateFadeTransition(to: newViewController) {
//                completion?()
//            }
//        }
//        else {
//            
//            if let rootViewController = self.rootViewController {
//                
//                newViewController.willMove(toParentViewController: nil)
//                self.addChildViewController(newViewController)
//                newViewController.view.frame = self.view.bounds
//                self.view.addSubview(newViewController.view)
//                rootViewController.removeFromParentViewController()
//                rootViewController.view.removeFromSuperview()
//                newViewController.didMove(toParentViewController: self)
//                self.rootViewController = newViewController
//                
//            }
//            else {
//                
//                self.addChildViewController(newViewController)
//                newViewController.view.frame = self.view.bounds
//                self.view.addSubview(newViewController.view)
//                newViewController.didMove(toParentViewController: self)
//                self.rootViewController = newViewController
//                
//            }
//            
//            completion?()
//        }
//    }
//    
//    private func animateFadeTransition(to newViewController: UIViewController, completion: (() -> Void)? = nil) {
//        
//        guard let rootViewController = self.rootViewController else {
//            assertionFailure("rootViewController must exist prior to animated transistion")
//            completion?()
//            return
//        }
//        
//        rootViewController.willMove(toParentViewController: nil)
//        addChildViewController(newViewController)
//        
//        transition(from: rootViewController, to: newViewController, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
//        }) { completed in
//            rootViewController.removeFromParentViewController()
//            newViewController.didMove(toParentViewController: self)
//            self.rootViewController = newViewController
//            completion?()
//        }
//    }
//    
//    //calls closure with the last presented vc
//    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
//        
//        assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
//        
//        guard let head = matchedRoutes.first else {
//            assertionFailure("Root should never be presented")
//            completion?(self, nil)
//            return
//        }
//        
//        let tail = Array(matchedRoutes.dropFirst())
//        
//        if let lvc = self.childLayoutVC(for: head) {
//            lvc.updateLayout(matchedRoute: head, state: state)
//            lvc.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
//        }
//        else {
//            assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
//            
//            self.childLayoutVCs = []
//            
//            //first instantiate the full VC stack
//            //then transistion
//            do {
//                
//                guard let childLayout = RSStateSelectors.layout(state, for: head.route.layoutIdentifier) else {
//                    completion?(nil, RSRouter.RSRouterError.noMatchingLayout(routeIdentifier: head.route.identifier, layoutIdentifier: head.route.layoutIdentifier))
//                    return
//                }
//                
//                let childVC = try childLayout.instantiateViewController(parent: self, matchedRoute: head)
//                
//                childVC.present(matchedRoutes: tail, animated: false, state: state) { (topVC, error) in
//                    if error != nil {
//                        completion?(nil, error)
//                    }
//                    else {
//                        
//                        self.childLayoutVCs = self.childLayoutVCs + [childVC]
//                        let nav = RSNavigationController()
//                        nav.pushViewController(childVC.viewController, animated: false)
//                        
//                        self.transition(to: nav, animated: animated, completion: {
//                            completion?(topVC, nil)
//                        })
//                        
//                    }
//                }
//            }
//            catch let error {
//                completion?(nil, error)
//            }
//            
//        }
//        
//    }
//
//}
