//
//  RSFeedbackViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/21/18.
//

import UIKit

open class RSFeedbackViewController: NSObject {

    var feedbackButtonImageView: UIImageView!
    var tapGesture: UITapGestureRecognizer!
    
    var window: UIWindow!
    
    func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2))
    }
    
    func topLeftCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        
        let xOffset = imageSize.width/2 + 20.0
        let yOffset = imageSize.height/2 + 20.0
        
        return CGPoint(x: xOffset, y: yOffset)
        
    }
    
    func topRightCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = (windowSize.width - imageSize.width/2) - 20.0
        let yOffset = imageSize.height/2 + 20.0
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func bottomLeftCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = imageSize.width/2 + 20.0
        let yOffset = (windowSize.height - imageSize.height/2) - 20.0
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func bottomRightCenter(windowSize: CGSize, imageSize: CGSize) -> CGPoint {
        let xOffset = (windowSize.width - imageSize.width/2) - 20.0
        let yOffset = (windowSize.height - imageSize.height/2) - 20.0
        
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
    
    
    public init(window: UIWindow) {
        
        super.init()
        
        let bundle = Bundle(for: RSFeedbackViewController.self)
        if let feedbackImage =  UIImage(named: "feedback", in: bundle, compatibleWith: nil) {
            let feedbackButton = UIImageView(image: feedbackImage)
            
            feedbackButton.contentMode = .scaleAspectFit
            feedbackButton.sizeToFit()
            feedbackButton.frame = CGRect(origin: CGPoint.zero, size: feedbackImage.size)
            feedbackButton.center = self.defaultCenter(windowSize: window.frame.size, imageSize: feedbackImage.size)
            debugPrint(feedbackButton)

            feedbackButton.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapGestureRecognizer.numberOfTapsRequired = 2
            feedbackButton.addGestureRecognizer(tapGestureRecognizer)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            feedbackButton.addGestureRecognizer(panGestureRecognizer)
            
            self.feedbackButtonImageView = feedbackButton
            window.addSubview(feedbackButtonImageView)
            
            self.window = window
        }
    }
    
//    func presentTextInputWindow()
    
    
    
    
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
            // handling code
        }
    }
    

}
