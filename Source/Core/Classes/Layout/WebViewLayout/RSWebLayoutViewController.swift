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
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url,
            url.absoluteString.hasPrefix("com.curiosityhealth.teamwork") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButton = self.layout.navButtonRight {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightButton.title, style: .plain, target: self, action: #selector(tappedRightBarButton))
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
        
        let remainder = self.matchedRoute.match.path.replacingOccurrences(of: prefix, with: "")
        debugPrint(remainder)
        
        if let state = self.store?.state,
            let urlBase = RSValueManager.processValue(jsonObject: self.webLayout.urlBase, state: state, context: self.context())?.evaluate() as? String,
            let url = URL(string: urlBase + remainder) {
            
            self.requestedURL = url
            
            let request = URLRequest(url: url)
            self.webView?.load(request)
            
        }
    }

}
