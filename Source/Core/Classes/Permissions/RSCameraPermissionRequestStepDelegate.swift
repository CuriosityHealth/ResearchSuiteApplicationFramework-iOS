//
//  RSCameraPermissionRequestStepDelegate.swift
//  Pods
//
//  Created by James Kizer on 2/18/19.
//

import UIKit
import AVFoundation

open class RSCameraPermissionRequestStepDelegate: RSPermissionRequestStepDelegate {
    
    public enum CameraPermissionRequestError: Error {
        case permissionDenied
    }
    
    public func permissionRequestViewControllerDidLoad(viewController: RSPermissionRequestStepViewController) {
        
    }
    
    public func requestPermissions(completion: @escaping ((Bool, Error?) -> ())) {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if granted {
                //access granted
                completion(true, nil)
            } else {
                completion(false, CameraPermissionRequestError.permissionDenied)
            }
        }
    }
    
    public func alertController(granted: Bool, error: Error) -> UIAlertController {
        let alertController = UIAlertController(title: "Grant Error", message: "Unable to access the camera. You can update this in your settings.", preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in

        }

        alertController.addAction(okAction)
        return alertController
        
    }
    
}
