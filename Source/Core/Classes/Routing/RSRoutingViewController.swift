//
//  RSRoutingViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//

import UIKit
import ReSwift
import ResearchKit

public protocol RSRootViewController {
    func lockScreen()
    func setContentHidden(hidden: Bool)
    var passcodeViewController: ORKPasscodeViewController? { get }
    var topViewController: UIViewController { get }
}

open class RSRoutingViewController: UIViewController, StoreSubscriber, RSLayoutViewController, RSRootViewController, ORKPasscodeDelegate {
    
    private var rootViewController: UIViewController! = nil
    
    public var identifier: String! {
        return "ROOT"
    }
    
    public var matchedRoute: RSMatchedRoute! {
        return nil
    }
    
    public var layout: RSLayout! {
        let state: RSState = self.store!.state
        return RSStateSelectors.layout(state, for: self.rootLayoutIdentifier)
    }
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController! {
        return nil
    }
    
    private var childLayoutVCs: [RSLayoutViewController] = []
    
    private func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    private func transition(to newViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if animated {
            self.animateFadeTransition(to: newViewController) {
                completion?()
            }
        }
        else {
            
            if let rootViewController = self.rootViewController {
                
                newViewController.willMove(toParentViewController: nil)
                self.addChildViewController(newViewController)
                newViewController.view.frame = self.view.bounds
                self.view.addSubview(newViewController.view)
                rootViewController.removeFromParentViewController()
                rootViewController.view.removeFromSuperview()
                newViewController.didMove(toParentViewController: self)
                self.rootViewController = newViewController
                
            }
            else {
                
                self.addChildViewController(newViewController)
                newViewController.view.frame = self.view.bounds
                self.view.addSubview(newViewController.view)
                newViewController.didMove(toParentViewController: self)
                self.rootViewController = newViewController
                
            }
            
            completion?()
        }
    }
    
    private func animateFadeTransition(to newViewController: UIViewController, completion: (() -> Void)? = nil) {
        
        guard let rootViewController = self.rootViewController else {
            assertionFailure("rootViewController must exist prior to animated transistion")
            completion?()
            return
        }
        
        rootViewController.willMove(toParentViewController: nil)
        addChildViewController(newViewController)
        
        transition(from: rootViewController, to: newViewController, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            rootViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
            self.rootViewController = newViewController
            completion?()
        }
    }
    
    //calls closure with the last presented vc
    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
        
        assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
        
        guard let head = matchedRoutes.first else {
            assertionFailure("Root should never be presented")
            completion?(self, nil)
            return
        }
        
        let tail = Array(matchedRoutes.dropFirst())
        
        if let lvc = self.childLayoutVC(for: head) {
            lvc.updateLayout(matchedRoute: head, state: state)
            lvc.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
        }
        else {
            assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
            
            self.childLayoutVCs = []
            
            //first instantiate the full VC stack
            //then transistion
            do {

                let childVC = try head.layout.instantiateViewController(parent: self, matchedRoute: head)
                
                childVC.present(matchedRoutes: tail, animated: false, state: state) { (topVC, error) in
                    if error != nil {
                        completion?(nil, error)
                    }
                    else {
                        
                        self.childLayoutVCs = self.childLayoutVCs + [childVC]
                        let nav = RSNavigationController()
                        nav.pushViewController(childVC.viewController, animated: false)
                        
                        self.transition(to: nav, animated: animated, completion: {
                            completion?(topVC, nil)
                        })
                        
                    }
                }
            }
            catch let error {
                completion?(nil, error)
            }
            
        }
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
        
    }
    
    public func layoutDidLoad() {
        
    }
    
    public func layoutDidAppear(initialAppearance: Bool) {
        
    }
    
    public func backTapped() {
        
        
    }
    

//    private let rootLayoutViewController: RSLayoutViewController
    
    open let rootLayoutIdentifier: String
    open let routeManager: RSRouteManager
    open let activityManager: RSActivityManager
    weak var store: Store<RSState>?
    public init(rootLayoutIdentifier: String, routeManager: RSRouteManager, activityManager: RSActivityManager, store: Store<RSState>) {
        self.rootLayoutIdentifier = rootLayoutIdentifier
        self.routeManager = routeManager
        self.activityManager = activityManager
        self.store = store
        super.init(nibName: nil, bundle: nil)
        store.subscribe(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private var state: RSState!
//    open func newState(state: RSState) {
////        self.state = state
//    }
    

    private var _visibleLayoutViewController: RSLayoutViewController? = nil
    open var visibleLayoutViewController: RSLayoutViewController? {
        return self._visibleLayoutViewController
    }
    
    open func newState(state: RSState) {
        
        //only route if the passcode view controller is NOT presented
        //NOTE: there is a race condition on sign out where the state is cleared but the passcode view controller is actully presented
        guard !RSStateSelectors.isPasscodePresented(state) && !self.isPasscodePresented() else {
            return
        }
        
        if let requestedPath = RSStateSelectors.requestedPath(state),
            !RSStateSelectors.isRouting(state) {
            
            if RSStateSelectors.forceReroute(state) {
                
                self.rootViewController.removeFromParentViewController()
                self.rootViewController.view.removeFromSuperview()
                self.rootViewController = nil
                
                self.childLayoutVCs = []
                
            }
            
            let hasRouted = self.rootViewController != nil
            //begin routing
            let beginRoutingAction = RoutingStarted(requestedPath: requestedPath)
            self.store?.dispatch(beginRoutingAction)
            
            self.handleRouteChange(newPath: requestedPath, animated: hasRouted, state: state) { (finalPath, error) in
                
                if let error = error {
                    let failureAction = ChangePathFailure(requestedPath: requestedPath, finalPath: finalPath, error: error)
                    self.store?.dispatch(failureAction)
                }
                else {
                    let successAction = ChangePathSuccess(requestedPath: requestedPath, finalPath: finalPath)
                    self.store?.dispatch(successAction)
                }
                
            }
            
        }
        else {
            
            guard !RSStateSelectors.isPresentingPasscode(state),
                !RSStateSelectors.isDismissingPasscode(state) else {
                    return
            }
            //otherwise, check to see if there is an activity to present
            if RSStateSelectors.shouldPresent(state) {
                self.store?.dispatch(RSActionCreators.presentActivity(on: self, activityManager: self.activityManager))
            }

            
        }

    }
 
    private func handleRouteChange(newPath: String, animated: Bool, state: RSState, completion: @escaping ((String, Error?) -> ())) {
        do {
            
            let routingInstructions = try RSRouter.generateRoutingInstructions(
                path: newPath,
                rootLayoutIdentifier: self.rootLayoutIdentifier,
                state: state,
                routeManager: self.routeManager
            )
            
            self.present(matchedRoutes: routingInstructions.routesStack, animated: animated, state: state, completion: { (visibleVC, error) in
                
                if error != nil {
                    completion(routingInstructions.path, error)
                    return
                }
                else {
                    completion(routingInstructions.path, nil)
                    return
                }
                
                
            })
        }
        catch let error {
            completion(newPath, error)
            assertionFailure(error.localizedDescription)
        }
        
    }
    
    open var passcodeViewController: ORKPasscodeViewController? {
        let state: RSState = self.store!.state
        return RSStateSelectors.passcodeViewController(state)
    }
    
    open func lockScreen() {
        
//        let state: RSState = self.state
        let state: RSState = self.store!.state
        guard RSStateSelectors.shouldShowPasscode(state) else {
            return
        }
        
        let vc = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        let uuid = UUID()
        self.store!.dispatch(PresentPasscodeRequest(uuid: uuid, passcodeViewController: vc))

        self.topViewController.present(vc, animated: false, completion: {
            self.store!.dispatch(PresentPasscodeSuccess(uuid: uuid, passcodeViewController: vc))
        })
    }
    
    private func dismissPasscodeViewController(_ animated: Bool) {
        
        let state: RSState = self.store!.state
        guard let passcodeViewController = RSStateSelectors.passcodeViewController(state) else {
            return
        }
        
        let uuid = UUID()
        self.store!.dispatch(DismissPasscodeRequest(uuid: uuid, passcodeViewController: passcodeViewController))
        passcodeViewController.presentingViewController?.dismiss(animated: animated, completion: {
            self.store!.dispatch(DismissPasscodeSuccess(uuid: uuid, passcodeViewController: passcodeViewController))
        })
    }
    
    private func resetPasscode() {
        
        let state: RSState = self.store!.state
        guard let passcodeViewController = RSStateSelectors.passcodeViewController(state) else {
            return
        }
        
        RSApplicationDelegate.appDelegate.signOut{ (signedOut, error) in
            passcodeViewController.presentingViewController?.dismiss(animated: false, completion: nil)
            // Dismiss the view controller unanimated
            //            dismissPasscodeViewController(false)
        }
    }
    
    // MARK: ORKPasscodeDelegate
    
    open func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        dismissPasscodeViewController(true)
    }
    
    open func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // Do nothing in default implementation
    }
    
    open func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
        
        let title = "Reset Passcode"
        let message = "In order to reset your passcode, you'll need to log out of the app completely and log back in using your email and password."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.resetPasscode()
        })
        alert.addAction(logoutAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func isPasscodePresented() -> Bool {
        return self.topViewController is ORKPasscodeViewController
    }
    
    open func setContentHidden(hidden: Bool) {
        
        
    }
    
    open var topViewController: UIViewController {
        var topViewController: UIViewController = self
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
}
