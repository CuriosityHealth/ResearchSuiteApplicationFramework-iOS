//
//  RSEmailCurrentLogActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 10/20/18.
//

import UIKit
import ReSwift
import Gloss
import MessageUI
import ResearchSuiteExtensions


open class RSEmailCurrentLogComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {
    open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}



open class RSEmailCurrentLogActionTransformer: RSActionTransformer {
    
    private static var mailComposeDelegate = RSEmailCurrentLogComposeDelegate()
    
    public static func supportsType(type: String) -> Bool {
        return "emailLogFile" == type
    }
    
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let fileLogger = RSApplicationDelegate.appDelegate.logger as? RSFileLogger else {
            return nil
        }
        
        return { state, store in
            
            //get current log file
            let logFileURL = fileLogger.logFile
            
            let alertController = UIAlertController(title: "DEBUG: Email Logs", message: "Would you like to email your current log file?", preferredStyle: .alert)
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: { alert -> Void in
                
                do {
                    
                    //generate email
                    if MFMailComposeViewController.canSendMail() {
                        let composeVC = MFMailComposeViewController()
                        //is this held strongly?
                        composeVC.mailComposeDelegate = RSEmailCurrentLogActionTransformer.mailComposeDelegate
                        
                        // Configure the fields of the interface.
                        //                composeVC.setToRecipients(emailStep.recipientAddreses)
                        let subject = "Log File"
                        composeVC.setSubject(subject)
                        
                        let logFileData = try Data(contentsOf: logFileURL)
                        composeVC.addAttachmentData(logFileData, mimeType: "application/text", fileName: logFileURL.lastPathComponent)
                        
                        // Present the view controller modally.
                        
                        if let routingViewController = RSApplicationDelegate.appDelegate.window?.rootViewController as? RSRoutingViewController {
                            composeVC.modalPresentationStyle = .fullScreen
                            routingViewController.topViewController.present(composeVC, animated: true, completion: nil)
                        }
                        
                    }
                    else {
                        //present error that mail not configured
                        let alertController = UIAlertController(title: "An Error Occurred", message: "Your device is not configured to send mail", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                            (action : UIAlertAction!) -> Void in })
                        alertController.addAction(okAction)
                        
                        if let routingViewController = RSApplicationDelegate.appDelegate.window?.rootViewController as? RSRoutingViewController {
                            routingViewController.topViewController.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }
                catch let error {
                    debugPrint(error)
                }
                
            })
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(cancelAction)
            alertController.addAction(emailAction)
            
//            if let routingViewController = self.window.rootViewController as? RSRoutingViewController {
//                routingViewController.topViewController.present(alertController, animated: true, completion: nil)
//            }
//
            if let routingViewController = RSApplicationDelegate.appDelegate.window?.rootViewController as? RSRoutingViewController {
                routingViewController.topViewController.present(alertController, animated: true, completion: nil)
            }
            
            
            return nil
        }
    }
    
}
