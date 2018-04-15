//
//  RSTabBarLayoutRedirectViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//

import UIKit

open class RSTabBarLayoutRedirectViewController: UIViewController {

    public var onFirstAppearance: (() -> ())?

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onFirstAppearance?()
        self.onFirstAppearance = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.onFirstAppearance?()
        self.onFirstAppearance = nil
    }

}
