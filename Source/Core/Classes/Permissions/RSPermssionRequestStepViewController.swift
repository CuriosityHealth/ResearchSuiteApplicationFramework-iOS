//
//  RSPermssionRequestStepViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

open class RSPermissionRequestStepViewController: RSQuestionViewController {
    
    var stackView: UIStackView!
    
    open var requestDelegate: RSPermissionRequestStepDelegate?
    private var requested = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        if let step = self.step as? RSPermissionRequestStep {
            self.requestDelegate = step.delegate
            
            var stackedViews: [UIView] = []
            if let image = step.image {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                stackedViews.append(imageView)
            }
            
            let stackView = UIStackView(arrangedSubviews: stackedViews)
            stackView.distribution = .equalCentering
            stackView.frame = self.contentView.bounds
            self.stackView = stackView
            
            self.contentView.addSubview(stackView)
        }
        
        self.requestDelegate?.permissionRequestViewControllerDidLoad(viewController: self)
        
    }
    
    override open func continueTapped(_ sender: Any) {
        
        guard let requestDelegate = self.requestDelegate else {
            return
        }
        
        if !self.requested {
            self.continueButtonEnabled = false
            self.requested = true
            requestDelegate.requestPermissions(completion: { (granted, error) in
                
                if granted && error == nil {
                    DispatchQueue.main.async {
                        self.notifyDelegateAndMoveForward()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.present(requestDelegate.alertController(granted: granted, error: error!), animated: true, completion: nil)
                        self.continueButtonEnabled = true
                        self.setContinueButtonTitle(title: "Continue")
                    }
                    
                }
                
            })
        }
        else {
            self.notifyDelegateAndMoveForward()
        }
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.stackView.frame = self.contentView.bounds
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stackView.frame = self.contentView.bounds
    }
    
}
