//
//  RSFeedbackViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/21/18.
//

import UIKit
import ResearchSuiteExtensions
import Gloss
import ResearchKit
import SimplePDF
import MessageUI

public struct RSFeedbackItem: Glossy {
    
    let feedback: String
    let screenshotBase64: String?
    
    public init(feedback: String, screenshot: UIImage?) {
        
        self.feedback = feedback
        self.screenshotBase64 = {
            guard let image = screenshot,
                let data: Data = image.pngData() else {
                    return nil
            }
            
            return data.base64EncodedString()
        }()
        
    }
    
    public init?(json: JSON) {
        
        guard let feedback: String = "feedback" <~~ json else {
                return nil
        }
        
        self.feedback = feedback
        self.screenshotBase64 = "screenshot" <~~ json
        
    }
    
    public func toJSON() -> JSON? {
        
        return jsonify([
            "feedback" ~~> self.feedback,
            "screenshot" ~~> self.screenshotBase64
            ])
    }
    
    
}

open class RSFeedbackViewController: NSObject, MFMailComposeViewControllerDelegate {
    

    var feedbackButtonImageView: UIView!
    var tapGesture: UITapGestureRecognizer!
//    var feedbackInputView
    var inputView: RSFeedbackInputView?
    
    var currentScreenShot: UIImage?
    
    var window: UIWindow!
    
    func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2))
    }
    
    func topLeftCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        
        let xOffset = imageSize.width/2 + 20.0
        let yOffset = imageSize.height/2 + 40.0
        
        return CGPoint(x: xOffset, y: yOffset)
        
    }
    
    func topRightCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = (windowSize.width - imageSize.width/2) - 20.0
        let yOffset = imageSize.height/2 + 40.0
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func bottomLeftCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = imageSize.width/2 + 20.0
        let yOffset = (windowSize.height - imageSize.height/2) - 80.0
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func bottomRightCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = (windowSize.width - imageSize.width/2) - 20.0
        let yOffset = (windowSize.height - imageSize.height/2) - 80.0
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func defaultCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        return bottomRightCenter(windowSize:windowSize, imageSize:imageSize)
    }
    
    
    func closestCenter(windowSize: CGSize, imageSize: CGSize, currentCenter: CGPoint) -> CGPoint {
        
        let centers: [CGPoint] = [
            self.topLeftCenter(windowSize: windowSize, imageSize: imageSize),
            self.topRightCenter(windowSize: windowSize, imageSize: imageSize),
            self.bottomLeftCenter(windowSize: windowSize, imageSize: imageSize),
            self.bottomRightCenter(windowSize: windowSize, imageSize: imageSize)
        ]
        
        let centerDistancePairs: [(CGPoint, CGFloat)] = centers.map { point in
            return (point, self.distanceBetween(p1: currentCenter, p2: point))
            }.sorted { (pair1, pair2) -> Bool in
                pair1.1 < pair2.1
        }
        
        return centerDistancePairs.first!.0
    }
    
    func animateToClosestCorner(currentCenter: CGPoint) {
        
        let closestCenter = self.closestCenter(windowSize: self.window.frame.size, imageSize: self.feedbackButtonImageView.frame.size, currentCenter: currentCenter)
        
        UIView.animate(withDuration: 0.2) {
            self.feedbackButtonImageView.center = closestCenter
        }
        
    }
    
    var feedbackQueue: RSGlossyQueue<RSFeedbackItem>!
    
    public init(window: UIWindow) {
        
        self.feedbackQueue = RSGlossyQueue(directoryName: "feedbackQueue", allowedClasses: [NSDictionary.self, NSArray.self])!
        
        super.init()
        
//        let bundle = Bundle(for: RSFeedbackViewController.self)
        
        
        
        if MFMailComposeViewController.canSendMail() {
            let buttonSize = CGSize(width: 60.0, height: 60.0)
            let feedbackButton = UIView()
            feedbackButton.backgroundColor = UIColor(red: 12.0/255.0, green: 76.0/255.0, blue: 194.0/255.0, alpha: 0.3)
            feedbackButton.layer.cornerRadius = 5;
            feedbackButton.layer.masksToBounds = true;
            
            feedbackButton.frame = CGRect(origin: CGPoint.zero, size: buttonSize)
            feedbackButton.center = self.defaultCenter(windowSize: window.frame.size, imageSize: buttonSize)

            feedbackButton.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapGestureRecognizer.numberOfTapsRequired = 2
            feedbackButton.addGestureRecognizer(tapGestureRecognizer)
            
            let finishedTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFinishedTap))
            finishedTapGestureRecognizer.numberOfTapsRequired = 3
            feedbackButton.addGestureRecognizer(finishedTapGestureRecognizer)
            
            tapGestureRecognizer.require(toFail: finishedTapGestureRecognizer)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            feedbackButton.addGestureRecognizer(panGestureRecognizer)
            
            self.feedbackButtonImageView = feedbackButton
            window.addSubview(feedbackButtonImageView)
            
            self.window = window
        }
    }
    
    func presentTextInputWindow() {
        
        let alertController = UIAlertController(title: "Add feedback", message: "You can add feedback here. It will be stored locally until you are ready to submit it by triple clicking on the icon.", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "Enter Second Name"
//            textField.lin
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let feedbackItem = RSFeedbackItem(feedback: firstTextField.text!, screenshot: self.currentScreenShot)
            do {
                try self.feedbackQueue.addGlossyElement(element: feedbackItem)
            } catch let error {
                
            }
            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        if let routingViewController = self.window.rootViewController as? RSRoutingViewController {
            routingViewController.topViewController.present(alertController, animated: true, completion: nil)
        }

    }
    
    func presentSubmitFeedbackWindow() {

        let alertController = UIAlertController(title: "Email Feedback", message: "Would you like to email your feedback?", preferredStyle: .alert)
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: { alert -> Void in

            do {

                //generate pdf data
                guard let pdfData = try self.generatePDF() else {
                    return
                }

                //generate email
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self

                    // Configure the fields of the interface.
                    //                composeVC.setToRecipients(emailStep.recipientAddreses)
                    let subject = "App Feedback"
                    composeVC.setSubject(subject)
                    composeVC.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: "feedback-\(UUID()).pdf")

                    // Present the view controller modally.
                    if let routingViewController = self.window.rootViewController as? RSRoutingViewController {
                        routingViewController.topViewController.present(composeVC, animated: true, completion: nil)
                    }

                }
                //ask if they want to clear the queue


            }
            catch let error {
                debugPrint(error)
            }

        })


        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(emailAction)

        if let routingViewController = self.window.rootViewController as? RSRoutingViewController {
            routingViewController.topViewController.present(alertController, animated: true, completion: nil)
        }
    }

    open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        let alertController = UIAlertController(title: "Clear Feedback?", message: "Would you like to delete all your feedback?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in

            do {
                try self.feedbackQueue.clear()
            }
            catch let error {
                debugPrint(error)
            }

        })

        let noAction = UIAlertAction(title: "No", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(noAction)
        alertController.addAction(yesAction)

        controller.dismiss(animated: true) {
            if let routingViewController = self.window.rootViewController as? RSRoutingViewController {
                routingViewController.topViewController.present(alertController, animated: true, completion: nil)
            }
        }

    }

    open func generatePDF() throws -> Data? {

        let letterSize = CGSize(width: 612, height: 792)
        let pdf = SimplePDF(pageSize: letterSize)

        let feedbackItems: [RSFeedbackItem] = try self.feedbackQueue.getGlossyElements().map { $0.element }

        if feedbackItems.count > 0 {

            pdf.addText("Feedback")

            feedbackItems.forEach { feedbackItem in

                pdf.beginNewPage()
                pdf.addText(feedbackItem.feedback)

                if let base64String = feedbackItem.screenshotBase64,
                    let data = Data(base64Encoded: base64String),
                    let image = UIImage(data: data) {
                    pdf.addImage(image)
                }
            }

            return pdf.generatePDFdata()

        }
        else {
            return nil
        }

    }
    
    open func flushQueue() {
        do {
            try self.feedbackQueue.clear()
        }
        catch let error {
            debugPrint(error)
        }
        
    }
    
    @objc
    func handlePan(sender: UIPanGestureRecognizer) {
        debugPrint(sender)
        
        guard let view = self.window.rootViewController?.view else {
            return
        }
        
        self.feedbackButtonImageView.center = sender.location(in: view)
        
        if sender.state == .ended {
            self.animateToClosestCorner(currentCenter: self.feedbackButtonImageView.center)
        }
    }
    
    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        debugPrint(sender)
        if sender.state == .ended {
            
            guard let rootViewController = self.window.rootViewController as? RSRoutingViewController else {
                return
            }
            
            self.currentScreenShot = rootViewController.takeScreenshot()
            self.presentTextInputWindow()
            
        }
    }
    
    @objc
    func handleFinishedTap(sender: UITapGestureRecognizer) {
        debugPrint(sender)
        if sender.state == .ended {
            
            self.presentSubmitFeedbackWindow()
            
        }
    }
    

}
