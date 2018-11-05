//
//  RSRoutingViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit
import Gloss

public protocol RSRootViewController {
    func lockScreen()
    func setContentHidden(hidden: Bool)
    var passcodeViewController: ORKPasscodeViewController? { get }
    var topViewController: UIViewController { get }
}

public struct RSRoutingEventLog: JSONEncodable {
    
    let requestedPath: String
    let finalPath: String?
    let visbleLayout: RSLayout?
    let error: Error?
    
    let screenshot: UIImage?
    
    let uuid: UUID = UUID()
    let timestamp: Date = Date()
    
    public func toJSON() -> JSON? {
        
        var base64Image: String? = {
            guard let image = self.screenshot,
                let data: Data = UIImagePNGRepresentation(image) else {
                return nil
            }
            
            return data.base64EncodedString()
            
        }()
        
        return jsonify([
            "requestedPath" ~~> self.requestedPath,
            "finalPath" ~~> (self.finalPath ?? "unknown"),
            "visibleLayout" ~~> (self.visbleLayout?.identifier ?? "unknown"),
            "screenshot" ~~> base64Image,
            "error" ~~> self.error?.localizedDescription,
            "uuid" ~~> self.uuid,
            Gloss.Encoder.encode(dateISO8601ForKey: "timestamp")(self.timestamp)
            ])
    }
    
}

public protocol RSRoutingDelegate: class {
    func logRoutingEvent(routingEventLog: RSRoutingEventLog)
}

open class RSRoutingViewController: UIViewController, StoreSubscriber, RSLayoutViewController, RSRootViewController, ORKPasscodeDelegate {
    
    static let TAG = "RSRoutingViewController"
    
    open func takeScreenshot() -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }

    
    public weak var routingDelegate: RSRoutingDelegate?
    
    private var rootViewController: UIViewController! = nil
    
    public var identifier: String! {
        return "ROOT"
    }
    
    public let uuid: UUID = UUID()
    
    public var matchedRoute: RSMatchedRoute! {
        return nil
    }
    
    open func reloadLayout() {
        self.childLayoutVCs.forEach({ $0.reloadLayout() })
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
    
//    var overlayView: UIView?
    var hiddenViewControllers: [UIViewController] = []
    var hiddenViewControllerImageViews: [UIImageView] = []
    
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
        
        //if we are in the middle of doing something, wait until we are done
        //maybe add more checks here
        
        //check for content hidden request
        if let setContentHiddenRequest = RSStateSelectors.setContentHiddenRequested(state),
            RSStateSelectors.settingContentHidden(state) == false,
            RSStateSelectors.isPresentingPasscode(state) == false,
            RSStateSelectors.isDismissing(state) == false {
            
            self.handleSetContentHidden(hidden: setContentHiddenRequest) {
                
            }
            
        }
        
        //passcode dismisses itself
        guard !RSStateSelectors.isPasscodePresented(state) && !self.isPasscodePresented() else {
            return
        }
        
        //check for present passcode request
        //once passcode is presented, we can set content hidden to false
        if RSStateSelectors.passcodeRequested(state) == true,
                RSStateSelectors.settingContentHidden(state) == false {
            
            self.handleLockScreen { [unowned self] (locked) in
                
                if locked {
                    self.setContentHidden(hidden: false)
                }
                
            }
            
        }
        
        if let pathChangeRequest = RSStateSelectors.pathChangeRequest(state),
            !RSStateSelectors.isRouting(state) {
            
            let forceReroute = pathChangeRequest.2
            if forceReroute {
                
                self.rootViewController.removeFromParentViewController()
                self.rootViewController.view.removeFromSuperview()
                self.rootViewController = nil
                
                self.childLayoutVCs = []
                
            }
            
            let hasRouted = self.rootViewController != nil
            //begin routing
            let beginRoutingAction = RoutingStarted(uuid: pathChangeRequest.0)
            self.store?.dispatch(beginRoutingAction)
            
            self.handleRouteChange(newPath: pathChangeRequest.1, uuid: pathChangeRequest.0, animated: hasRouted, state: state) { (finalPath, error) in
                
                if let error = error {
                    let failureAction = ChangePathFailure(uuid: pathChangeRequest.0, requestedPath: pathChangeRequest.1, finalPath: finalPath, error: error)
                    self.store?.dispatch(failureAction)
                }
                else {
                    let successAction = ChangePathSuccess(uuid: pathChangeRequest.0, requestedPath: pathChangeRequest.1, finalPath: finalPath)
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
 
    public func canRoute(newPath: String, state: RSState) -> Bool {
//        do {
//            let _ = try RSRouter.generateRoutingInstructions(
//                path: newPath,
//                rootLayoutIdentifier: self.rootLayoutIdentifier,
//                state: state,
//                routeManager: self.routeManager
//            )
//            return true
//        }
//        catch _ {
//            return false
//        }
        
        return RSRouter.canRoute(
            path: newPath,
            rootLayoutIdentifier: self.rootLayoutIdentifier,
            state: state,
            routeManager: self.routeManager
        )
    }
    
    private func handleRouteChange(newPath: String, uuid: UUID, animated: Bool, state: RSState, completion: @escaping ((String, Error?) -> ())) {
        do {
            
            let routingInstructions = try RSRouter.generateRoutingInstructions(
                path: newPath,
                uuid: uuid,
                rootLayoutIdentifier: self.rootLayoutIdentifier,
                state: state,
                routeManager: self.routeManager
            )
            
            self.present(matchedRoutes: routingInstructions.routesStack, animated: animated, state: state, completion: { (visibleVC, error) in
                
                if error != nil {
                    let routingEventLog = RSRoutingEventLog(requestedPath: newPath, finalPath: routingInstructions.path, visbleLayout: visibleVC?.layout, error: error, screenshot: nil)
                    
                    self.routingDelegate?.logRoutingEvent(routingEventLog: routingEventLog)
                    completion(routingInstructions.path, error)
                    return
                }
                else {
                    
                    RSHelpers.delay(1.0, closure: {
                        let routingEventLog = RSRoutingEventLog(requestedPath: newPath, finalPath: routingInstructions.path, visbleLayout: visibleVC?.layout, error: error, screenshot: self.takeScreenshot())
                        self.routingDelegate?.logRoutingEvent(routingEventLog: routingEventLog)
                    })
                    
                    completion(routingInstructions.path, nil)
                    return
                }
                
                
            })
        }
        catch let error {
            let routingEventLog = RSRoutingEventLog(requestedPath: newPath, finalPath: nil, visbleLayout: nil, error: error, screenshot: nil)
            self.routingDelegate?.logRoutingEvent(routingEventLog: routingEventLog)
            completion(newPath, error)
        }
        
    }
    
    open var passcodeViewController: ORKPasscodeViewController? {
        let state: RSState = self.store!.state
        return RSStateSelectors.passcodeViewController(state)
    }
    
    open func lockScreen() {
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.store!.dispatch(RequestPasscode(uuid: UUID()))
        }
    }
    
    private func handleLockScreen(completion: @escaping (Bool)->()) {
        
        let state: RSState = self.store!.state
        guard RSStateSelectors.shouldShowPasscode(state) else {
            completion(false)
            return
        }
        
        let vc = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        let uuid = UUID()
        self.store!.dispatch(PresentPasscodeRequest(uuid: uuid, passcodeViewController: vc))
        
        RSApplicationDelegate.appDelegate.logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Presenting Passcode View")
        
        self.topViewController.present(vc, animated: false, completion: {
            RSApplicationDelegate.appDelegate.logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Passcode View Presented")
            self.store!.dispatch(PresentPasscodeSuccess(uuid: uuid, passcodeViewController: vc))
            completion(true)
        })
        
    }
    
    private func dismissPasscodeViewController(_ animated: Bool) {
        
//        debugPrint(self.store)
        let state: RSState = self.store!.state
        guard let passcodeViewController = RSStateSelectors.passcodeViewController(state) else {
            return
        }
        
        let uuid = UUID()
        self.store!.dispatch(DismissPasscodeRequest(uuid: uuid, passcodeViewController: passcodeViewController))
        RSApplicationDelegate.appDelegate.logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Dismissing Passcode View")
        passcodeViewController.presentingViewController?.dismiss(animated: animated, completion: {
            RSApplicationDelegate.appDelegate.logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Passcode View Dismissed")
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
    
    private func handleSetContentHidden(hidden: Bool, completion: @escaping ()->()) {
        let logger = RSApplicationDelegate.appDelegate.logger
        logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Setting contents hidden to \(hidden)")
        
        let uuid = UUID()
        self.store!.dispatch(SetContentHiddedStarted(uuid: uuid, hidden: hidden))
        
        if let infoDict = Bundle.main.infoDictionary,
            let launchStoryboardName = infoDict["UILaunchStoryboardName"] as? String,
            let viewController = UIStoryboard(name: launchStoryboardName, bundle: nil).instantiateInitialViewController() {
            
            if hidden {
                
                let vc = self.topViewController
                logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Presenting initial view controller")
                vc.present(viewController, animated: false) {
                    
                    logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Presented initial view controller")
                    
                    var screenshotImage:UIImage?
                    let layer = UIApplication.shared.keyWindow!.layer
                    let scale = UIScreen.main.scale
                    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
                    
                    if let context = UIGraphicsGetCurrentContext() {
                        layer.render(in:context)
                        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        if let image = screenshotImage {
                            
                            logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Got screenshot")
                            
                            let imageView = UIImageView(frame: vc.view.bounds)
                            imageView.image = image
                            imageView.contentMode = .scaleToFill
                            vc.view.addSubview(imageView)
                            
                            self.hiddenViewControllers = self.hiddenViewControllers + [vc]
                            self.hiddenViewControllerImageViews = self.hiddenViewControllerImageViews + [imageView]
                            
                            logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Dismissing View Controller")
                            viewController.dismiss(animated: false, completion: {
                                logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Dismissed View Controller")
                                completion()
                                
                                self.store!.dispatch(SetContentHiddedCompleted(uuid: uuid, hidden: hidden))
                            })
                            return
                        }
                    }
                    
                    vc.view.isHidden = hidden
                    self.hiddenViewControllers = self.hiddenViewControllers + [vc]
                    logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Couldn't get screenshipt, dismissing View Controller")
                    viewController.dismiss(animated: false, completion: {
                        logger?.log(tag: RSRoutingViewController.TAG, level: .info, message: "Dismissed View Controller")
                        completion()
                        self.store!.dispatch(SetContentHiddedCompleted(uuid: uuid, hidden: hidden))
                    })
                    return
                    
                }
                
            }
            else {
                self.hiddenViewControllers.forEach({ $0.view.isHidden = false })
                self.hiddenViewControllerImageViews.forEach({ $0.removeFromSuperview() })
                completion()
                self.store!.dispatch(SetContentHiddedCompleted(uuid: uuid, hidden: hidden))
            }
        }
        else {
            if hidden {
                let vc = self.topViewController
                //                debugPrint(hidden)
                vc.view.isHidden = hidden
                self.hiddenViewControllers = self.hiddenViewControllers + [vc]
                completion()
                self.store!.dispatch(SetContentHiddedCompleted(uuid: uuid, hidden: hidden))
            }
            else {
                self.hiddenViewControllers.forEach({ $0.view.isHidden = false })
                completion()
                self.store!.dispatch(SetContentHiddedCompleted(uuid: uuid, hidden: hidden))
            }
        }
    }
    
    open func setContentHidden(hidden: Bool) {
        
        self.store!.dispatch(RequestSetContentHidden(hidden: hidden))
        
        
    }
    
    open var topViewController: UIViewController {
        var topViewController: UIViewController = self
        while (topViewController.presentedViewController != nil &&
            topViewController.presentedViewController != self.passcodeViewController ) {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
}
