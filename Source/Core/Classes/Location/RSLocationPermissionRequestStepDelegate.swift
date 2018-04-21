//
//  RSLocationPermissionRequestStepDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/8/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ReSwift
import CoreLocation

open class RSLocationPermissionRequestStepDelegate: RSPermissionRequestStepDelegate, StoreSubscriber {
    
    enum LocationPermissionRequestError: Error {
        case locationServicesDisabled
        case regionMonitoringNotAvailable
        case insufficentPermissions
    }
    
    var completion: ((Bool, Error?) -> ())?
    var store: Store<RSState> {
        return RSApplicationDelegate.appDelegate.store
    }
    
    var lastAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func permissionRequestViewControllerDidLoad(viewController: RSPermissionRequestStepViewController) {
        
    }
    
    public func requestPermissions(completion: @escaping ((Bool, Error?) -> ())) {
        
        if !CLLocationManager.locationServicesEnabled() {
            completion(false, LocationPermissionRequestError.locationServicesDisabled)
        } else if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            completion(false, LocationPermissionRequestError.regionMonitoringNotAvailable)
        } else if let state = self.store.state,
            RSStateSelectors.locationAuthorizationStatus(state) == .authorizedAlways {
            completion(true, nil)
        } else if let state = self.store.state,
            RSStateSelectors.locationAuthorizationStatus(state) == .notDetermined {
            
            self.lastAuthorizationStatus = RSStateSelectors.locationAuthorizationStatus(state)
            
            //perform authoriztion request
            self.completion = completion
            //request
            self.store.subscribe(self)
            let request = RSActionCreators.requestLocationAuthorization(always: true)
            self.store.dispatch(request)
        }
        else {
            completion(false, LocationPermissionRequestError.insufficentPermissions)
        }
    }
    
    public func alertController(granted: Bool, error: Error) -> UIAlertController {
        
        switch error {
        case LocationPermissionRequestError.locationServicesDisabled:
            let alertController = UIAlertController(title: "Location Services Disabled", message: "Please turn on location services to continue.", preferredStyle: UIAlertControllerStyle.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(okAction)
            return alertController
            
        case LocationPermissionRequestError.regionMonitoringNotAvailable:
            let alertController = UIAlertController(title: "Geofence Monitoring Not Supported", message: "Your phone does not support geofencing.", preferredStyle: UIAlertControllerStyle.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(okAction)
            return alertController
            
        case LocationPermissionRequestError.insufficentPermissions:
            let alertController = UIAlertController(title: "Insufficient Permissions", message: "In order to function properly, the application always needs location access. You can adjust this in your settings.", preferredStyle: UIAlertControllerStyle.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(okAction)
            return alertController
            
        default:
            
            let alertController = UIAlertController(title: "Error", message: "An error occurred", preferredStyle: UIAlertControllerStyle.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(okAction)
            return alertController
        }
        
    }
    
    
    public func newState(state: RSState) {
        
        //monitor a change in authorization status
        let authorizationStatus = RSStateSelectors.locationAuthorizationStatus(state)
        if self.lastAuthorizationStatus != authorizationStatus,
            let completion = self.completion {
            self.lastAuthorizationStatus = authorizationStatus
            self.completion = completion
            
            if authorizationStatus == .authorizedAlways {
                completion(true, nil)
            }
            else {
                completion(false, LocationPermissionRequestError.insufficentPermissions)
            }
        }
        
        
    }

}
