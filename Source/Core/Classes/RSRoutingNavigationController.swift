//
//  RSRoutingNavigationController.swift
//  Pods
//
//  Created by James Kizer on 7/11/17.
//
//

import UIKit
import ReSwift

public protocol RSRouterDelegate: class {
//    func presentLayout(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Swift.Void)?)
    func showRoute(route: RSRoute, state: RSState, store: Store<RSState>, completion: @escaping (Bool, RSLayoutViewControllerProtocol?) -> Swift.Void)
    func setContentHidden(contentHidden: Bool)
}

open class RSRoutingNavigationController: UINavigationController, StoreSubscriber, RSRouterDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    
    var store: Store<RSState>!
    var layoutManager: RSLayoutManager!
    var activityManager: RSActivityManager!
    
    var onDidShow: ((UIViewController) -> Void)?
    
    var isPopping: Bool = false

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        self.interactivePopGestureRecognizer?.isEnabled = false
        
        self.store.subscribe(self)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func setContentHidden(contentHidden: Bool) {
        if let vc = self.presentedViewController {
            vc.view.isHidden = contentHidden
        }
        
        self.view.isHidden = contentHidden
    }

    open func presentLayout(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        self.transition(toRootViewController: viewController, animated: animated, completion: { presented in
            completion?(presented)
        })
    }

    public func navigationBar(_ navigationBar: UINavigationBar,
                              shouldPop item: UINavigationItem) -> Bool {
        
        if self.isPopping {
            return true
        }
        else {
            if let lvc = self.topViewController as? RSLayoutViewControllerProtocol {
                lvc.backTapped()
            }
            return false
        }
        
    }
    
    open func showRoute(route: RSRoute, state: RSState, store: Store<RSState>, completion: @escaping (Bool, RSLayoutViewControllerProtocol?) -> Void) {
        
        
        //perhaps a better method for doing this is to translate layouts identifiers into URLs
        // i.e., /home/settings
        // for now, the current system appears like it should work for basic apps
        
        //here, check to see that if the route has a parent
        //its parent is the current route
        //NOTE: In the future, we can update this to remove the constraint
        //however, this should be fine for now
        
        //I HAVE NO IDEA HOW THIS WILL WORK FOR TAB BARS!!
        
        //we can either set the root layout, push a layout onto the stack, or pop the layout off
        //if we are setting the root, the selected route will not have a parent and it will not be the parent of the current route
        
        //if we are to push a layout onto the stack, current route will be the parent of the selected route
        
        //if we are to pop a layout off the stack, the selected route will the the parent of the current route
        
        
        let currentRoute: RSRoute?  = RSStateSelectors.currentRoute(state)
        let currentRouteIdentifier: String? = currentRoute?.identifier
        let currentRouteParent: String? = currentRoute?.parent
        let newParent: String? = route.parent
        let newIdentifier: String = route.identifier
        
        if newParent == nil && newIdentifier != currentRouteParent {
            guard let layoutVC = RSActionCreators.generateLayout(for: route, state: state, store: store, layoutManager: layoutManager) else {
                completion(false, nil)
                return
            }
            
            self.transition(toRootViewController: layoutVC, animated: currentRoute != nil, completion: { presented in
                completion(presented, layoutVC as? RSLayoutViewControllerProtocol)
            })
        }
        else if currentRouteIdentifier != nil,
            newParent != nil,
            currentRouteIdentifier! == newParent! {
            
            guard let layoutVC = RSActionCreators.generateLayout(for: route, state: state, store: store, layoutManager: layoutManager) else {
                completion(false, nil)
                return
            }
            
            self.onDidShow = { vc in
                assert(layoutVC == vc)
                completion(true, vc as? RSLayoutViewControllerProtocol)
            }
            
            self.pushViewController(layoutVC, animated: true)
            
        }
        else if currentRouteParent != nil,
            currentRouteParent! == newIdentifier {
            
            //search for correct view controller in stack
            
            self.onDidShow = { [weak self] vc in
                self?.isPopping = false
                completion(true, vc as? RSLayoutViewControllerProtocol)
            }
            
            self.isPopping = true
            self.popViewController(animated: true)
            
        }
        else {
            assertionFailure("Invalid routing configuration")
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        self.onDidShow?(viewController)
        self.onDidShow = nil
        
    }

    //there is a bug when we are presenting a modal view controller and we reset the rootViewController
    //note that when we move to the logic being owned by the state, we can account for this
    //i.e., check to see if something is presented before we re-route
    //also, check to see if we are rerouting before we present
    open func transition(toRootViewController: UIViewController, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        if (animated) {
            
            let snapshot:UIView = (self.topViewController?.view.snapshotView(afterScreenUpdates: true))!
            
            self.viewControllers = [toRootViewController]
            toRootViewController.view.addSubview(snapshot)
            
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview()
                completion?(value)
            })
        }
        else {
            self.viewControllers = [toRootViewController]
            completion?(true)
        }
        
    }
    
    open func newState(state: RSState) {
        
        //only route if the passcode view controller is NOT presented
        guard !RSStateSelectors.isPasscodePresented(state) else {
            return
        }
        
        //first, lets check to see if there is a new layout to route
        let routes = RSStateSelectors.routes(state)
        let firstRouteOpt = routes.first { (route) -> Bool in
            
            guard let predicate = route.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }
        
        if let firstRoute = firstRouteOpt,
            RSStateSelectors.shouldRoute(state, route: firstRoute) {
            self.store.dispatch(RSActionCreators.setRoute(route: firstRoute, layoutManager: self.layoutManager, delegate: self))
            return
        }
            
        guard !RSStateSelectors.isPresentingPasscode(state),
            !RSStateSelectors.isDismissingPasscode(state) else {
                return
        }
            //otherwise, check to see if there is an activity to present
        if RSStateSelectors.shouldPresent(state) {
            self.store.dispatch(RSActionCreators.presentActivity(on: self, activityManager: self.activityManager))
        }
        
        
        
    }
    
    open func generateLayout(for route: RSRoute, state: RSState) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
            return nil
        }
        return self.layoutManager.generateLayout(layout: layout, store: self.store)
    }

}
