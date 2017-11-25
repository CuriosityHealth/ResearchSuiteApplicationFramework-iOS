//
//  RSLocationManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/25/17.
//

import UIKit
import CoreLocation
import ReSwift

open class RSLocationManager: NSObject, CLLocationManagerDelegate, StoreSubscriber {
    
    weak var store: Store<RSState>?
    let locationManager: CLLocationManager
    
    public init(store: Store<RSState>) {
        self.store = store
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    public func stopMonitoringLocations() {
        
    }
    
    public func newState(state: RSState) {
        
        self.doRegionProcessing(state: state)
        
    }
    
    public func doRegionProcessing(state: RSState) {
        //check for proper authorization
        //for region monitoring, we need always authorization
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            return
        }
        
        
    }
    
    public func requestLocationAuthorization(always: Bool) {
        if always {
            let currentStatus = CLLocationManager.authorizationStatus()
            if currentStatus == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            }
            else {
                self.store?.dispatch(RSActionCreators.completeLocationAuthorizationRequest(status: currentStatus))
            }
            
        }
        else {
            let currentStatus = CLLocationManager.authorizationStatus()
            if currentStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
            else {
                self.store?.dispatch(RSActionCreators.completeLocationAuthorizationRequest(status: currentStatus))
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //process onSuccesss action
        self.processLocationUpdate(manager, locations: locations, error: nil)
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        //process onFailure
        self.processLocationUpdate(manager, locations: nil, error: error)
    }
    
    public func processLocationUpdate(_ manager: CLLocationManager, locations: [CLLocation]?, error: Error?) {
        
        //process onSuccess Actions
        if let locationsToProcess = locations {
            
        }
        else if let err = error {
            //process onFailure Actions
            
        }
        
        //process finally actions
        
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.store?.dispatch(RSActionCreators.completeLocationAuthorizationRequest(status: status))
        
    }
    
    
    

}
