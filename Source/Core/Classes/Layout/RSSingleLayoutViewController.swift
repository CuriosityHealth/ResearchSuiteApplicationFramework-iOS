//
//  RSSingleLayoutViewController.swift
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

public protocol RSSingleLayoutViewController: class, RSLayoutViewController {
    
    var childLayoutVCs: [RSLayoutViewController] { get set }
    func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController?
    
}

extension RSSingleLayoutViewController {
    
    public func dismissChildLayout(childVC: RSLayoutViewController, animated: Bool, completion: ((Error?) -> Void)?) {
        guard let nav = self.viewController.navigationController as? RSNavigationController else {
            assertionFailure("unable to get nav controller")
            completion?(nil)
            return
        }
        
        nav.popViewController(layoutVC: childVC, animated: animated) { (viewController) in
            self.childLayoutVCs = self.childLayoutVCs.filter { $0.identifier != childVC.identifier }
            completion?(nil)
        }
    }
    
    public func presentChildLayout(matchedRoute: RSMatchedRoute, animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {

        //check to see if child exists
        if let childVC = self.childLayoutVC(for: matchedRoute) {
            assertionFailure("Do we ever get here?? If not, we should probably remove this")
            childVC.updateLayout(matchedRoute: matchedRoute, state: state)
            completion?(childVC, nil)
        }
        else {
            guard let nav = self.viewController.navigationController as? RSNavigationController else {
                assertionFailure("unable to get nav controller")
                completion?(nil, nil)
                return
            }

            do {
                let layoutVC = try matchedRoute.layout.instantiateViewController(parent: self, matchedRoute: matchedRoute)
                self.childLayoutVCs = self.childLayoutVCs + [layoutVC]
                nav.pushViewController(layoutVC.viewController, animated: animated) {
                    completion?(layoutVC, nil)
                }
            }
            catch let error {
                completion?(nil, error)
            }
        }

    }

    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {

        //this type of viewController should have 0 or 1 children
        assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")

        if let head = matchedRoutes.first {
            let tail = Array(matchedRoutes.dropFirst())


            //if this child vc already exists, update it and continue
            if let lvc = childLayoutVC(for: head) {
                lvc.updateLayout(matchedRoute: head, state: state)
                lvc.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                return
            }
            else {

                let presentAnimated = tail.count == 0 && animated
                //if this vc does not yet exist, we will need to instantiate it
                //however, since this VC is just part of a linear stream of VCs in nav controller, first
                //see if there is an existing child VC. if there is, dismiss it

                //this type of viewController should have 0 or 1 children
                assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
                if let existingChild = self.childLayoutVCs.first {
                    self.dismissChildLayout(childVC: existingChild, animated: animated) { (error) in
                        if error != nil {
                            completion?(nil, error)
                        }
                        else {
                            self.presentChildLayout(matchedRoute: head, animated: presentAnimated, state: state) { (lvc, error) in
                                if error != nil {
                                    completion?(nil, error)
                                }
                                else {
                                    assert(lvc != nil)
                                    lvc!.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                                }
                            }
                        }
                    }
                }
                else {

                    self.presentChildLayout(matchedRoute: head, animated: presentAnimated, state: state) { (lvc, error) in
                        if error != nil {
                            completion?(nil, error)
                        }
                        else {
                            assert(lvc != nil)
                            lvc!.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                        }
                    }
                }
            }
        }
        else {

            assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
            if let existingChild = self.childLayoutVCs.first {
                self.dismissChildLayout(childVC: existingChild, animated: animated) { (error) in
                    if error != nil {
                        completion?(nil, error)
                    }
                    else {
                        completion?(self, nil)
                    }
                }
            }
            else {
                completion?(self, nil)
            }

        }

    }
}
