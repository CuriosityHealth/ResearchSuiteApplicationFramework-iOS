//
//  RSPDFViewerViewController.swift
//  Pods
//
//  Created by James Kizer on 2/28/19.
//

import UIKit
import WebKit
import SnapKit

class RSPDFViewerViewController: UIViewController {

    public var pdfFilePath: String!
    var webView: WKWebView!

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //set up web view
        self.webView = WKWebView()
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        if let requestedURL = URL(string: self.pdfFilePath) {
            let request = URLRequest(url: requestedURL)
            self.webView.load(request)
        }
        
    }
}
