//
//  RSWebLayoutViewController.swift
//  Pods
//
//  Created by James Kizer on 5/24/18.
//

import UIKit
import ReSwift
import Gloss
//import LS2SDK
import SnapKit
import WebKit

open class RSWebLayoutViewController: UIViewController, StoreSubscriber, RSSingleLayoutViewController, WKNavigationDelegate {
    
    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    var state: RSState?
    var lastState: RSState?
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }

    var webLayout: RSWebLayout! {
        return self.layout as! RSWebLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var hasAppeared: Bool = false
    
    var webView: WKWebView!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        if let url = navigationAction.request.url,
//            url.absoluteString.hasPrefix("com.curiosityhealth.replace-with-current-app-schema"),
//            let appURLScheme = RSApplicationDelegate.appDelegate.appURLScheme() {
//
//            let newURLPath = url.absoluteString.replacingOccurrences(of: "com.curiosityhealth.replace-with-current-app-schema", with: appURLScheme)
//            if let newURL = URL(string: newURLPath) {
//                UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
//                decisionHandler(.cancel)
//                return
//            }
//        }
//
//        decisionHandler(.allow)
//        return
//    }
    
    //convert from http://localhost:7000/contentPath -> appURLScheme://layoutPath/contentPath
    func generateAppRouteURL(url: URL) -> URL? {
        
        //add parent match path to prefix, remove everything after that
        let parentMatchPath = self.parentLayoutViewController.matchedRoute.match.path
        guard let browserPath = self.matchedRoute.route.path as? RSBrowserPath else {
            return nil
        }
        
        let browserPathPrefix = browserPath.prefix
        
        let prefix = parentMatchPath + browserPathPrefix
        
        
        guard let state = self.store?.state,
        let urlBase = RSValueManager.processValue(jsonObject: self.webLayout.urlBase, state: state, context: self.context())?.evaluate() as? String,
            url.absoluteString.hasPrefix(urlBase),
            let appURLScheme = RSApplicationDelegate.appDelegate.appURLScheme() else {
                return nil
        }
        
        let appURLLayoutBase: String = "\(appURLScheme)://\(prefix)"
        
        let newURLPath = url.absoluteString.replacingOccurrences(of: urlBase, with: appURLLayoutBase)
        return URL(string: newURLPath)
        
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        //hooking into back / forward navigation trashes the stack
        //need to find a way to record these events without necessarily messing with them
//        if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward {
        if navigationAction.navigationType == .linkActivated {
        
            if let url = navigationAction.request.url {
                //open it locally
                if url.absoluteString.hasPrefix("com.curiosityhealth.replace-with-current-app-schema") {
                    
                    if let appURLScheme = RSApplicationDelegate.appDelegate.appURLScheme() {
                        let newURLPath = url.absoluteString.replacingOccurrences(of: "com.curiosityhealth.replace-with-current-app-schema", with: appURLScheme)
                       
                        if let newURL = URL(string: newURLPath) {
                            UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                }
                    //this trashes the stack
//                else if let appURL = self.generateAppRouteURL(url: url) {
//                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
////                    decisionHandler(.cancel)
////                    return
//                }
                else if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    print(url)
                    print("Redirected to browser. No need to open it locally")
                }
                
            }
            
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
        
    }
    
    var requestedURL: URL?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        
//        var rightBarButtonItems: [UIBarButtonItem] = []
//        if let rightButtons = self.layout.rightNavButtons {
//            
//            let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
//                button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
//            }
//            
//            let rightBarButtons = rightButtons.compactMap { (layoutButton) -> UIBarButtonItem? in
//                return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap)
//            }
//            
//            rightBarButtonItems = rightBarButtonItems + rightBarButtons
//        }
        
        let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
            button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
        }
        
        self.navigationItem.rightBarButtonItems = self.layout.rightNavButtons?.compactMap { (layoutButton) -> UIBarButtonItem? in
            return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
        }
        
        //set up web view
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        if let requestedURL = self.requestedURL {

            let request = URLRequest(url: requestedURL)
            self.webView.load(request)

        }
        else if let state = self.store?.state {
            self.updateLayout(matchedRoute: self.matchedRoute, state: state)
        }
        
        self.store?.subscribe(self)

        self.layoutDidLoad()
    }
    
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    @objc
    func tappedRightBarButton() {
        guard let button = self.layout.navButtonRight else {
            return
        }
        
        button.onTapActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON, extraContext: [String : AnyObject]? = nil) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(extraContext: extraContext), store: store)
        }
    }
    
    open func newState(state: RSState) {
        self.state = state
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            self.processAction(action: action)
        })
        
    }
    
    open func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                self.processAction(action: action)
            })
        }
        
    }
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
 
    
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        self.matchedRoute = matchedRoute
        
        //add parent match path to prefix, remove everything after that
        let parentMatchPath = self.parentLayoutViewController.matchedRoute.match.path
        guard let browserPath = self.matchedRoute.route.path as? RSBrowserPath else {
            return
        }
        
        let browserPathPrefix = browserPath.prefix
        
        let prefix = parentMatchPath + browserPathPrefix
        debugPrint(prefix)
        
        guard self.matchedRoute.match.path.hasPrefix(prefix) else {
            return
        }
        
        
        let remainder: String = {
            var remainder = self.matchedRoute.match.path.replacingOccurrences(of: prefix, with: "")
            if remainder.count == 0 {
                remainder = "/index.html"
            }
            else if remainder.last! == "/" {
                remainder = remainder + "index.html"
            }
            return remainder
        }()
        
        debugPrint(remainder)
        
        //if the remainder specifies a directory, append index.html
//        if remainder.last
        
        if let state = self.store?.state,
            let urlBase = RSValueManager.processValue(jsonObject: self.webLayout.urlBase, state: state, context: self.context())?.evaluate() as? String,
            let url = URL(string: urlBase + remainder) {
            
            self.requestedURL = url
            
            let request = URLRequest(url: url)
            self.webView?.load(request)
            
        }
    }

}
