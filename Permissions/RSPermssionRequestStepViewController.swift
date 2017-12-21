//
//  RSPermssionRequestStepViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//

import UIKit
import ResearchSuiteExtensions

open class RSPermissionRequestStepViewController: RSQuestionViewController {
    
    open var requestDelegate: RSPermissionRequestStepDelegate?
    private var requested = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        if let step = self.step as? RSPermissionRequestStep {
            self.setContinueButtonTitle(title: step.buttonText)
            self.requestDelegate = step.delegate
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
    
}
