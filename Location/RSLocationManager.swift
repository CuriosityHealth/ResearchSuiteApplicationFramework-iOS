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
    
    enum LocationManagerError: Error {
        case locationManagerDisabled
    }
    
    weak var store: Store<RSState>?
    let locationManager: CLLocationManager
    let config: RSLocationManagerConfiguration
    
    public typealias FetchLocationCompletion = ([CLLocation]?, Error?) -> ()
    var fetchLocationCompletion: FetchLocationCompletion?
    
    public init(store: Store<RSState>, config: RSLocationManagerConfiguration) {
        self.store = store
        self.locationManager = CLLocationManager()
        self.config = config
        super.init()
        self.locationManager.delegate = self
    }
    
    public func stopMonitoringLocations() {
        
    }
    
    public func newState(state: RSState) {
        
        self.doRegionProcessing(state: state)
        
    }
    
    public func fetchCurrentLocation(completion: @escaping FetchLocationCompletion) {
        self.fetchLocationCompletion = completion
        self.locationManager.requestLocation()
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
        
        guard let actions = self.config.locationConfig?.onUpdateActions,
            let store = self.store else {
            return
        }
        
        //completion handler should clear isFetching flag
        if let completion = self.fetchLocationCompletion {
            completion(locations, error)
            self.fetchLocationCompletion = nil
        }
        
        //process onSuccess Actions
        if let locationsToProcess = locations {
            locationsToProcess.forEach { location in
                RSActionManager.processActions(actions: actions.onSuccessActions, context: ["sensedLocation": location], store: store)
            }
        }
        else if let _ = error {
            //process onFailure Actions
            RSActionManager.processActions(actions: actions.onFailureActions, context: [:], store: store)
        }
        
        //process finally actions
        RSActionManager.processActions(actions: actions.finallyActions, context: [:], store: store)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if let state = self.store?.state,
            RSStateSelectors.isRequestingLocationAuthorization(state) {
            self.store?.dispatch(RSActionCreators.completeLocationAuthorizationRequest(status: status))
        }
        else {
            self.store?.dispatch(RSActionCreators.setLocationAuthorizationStatus(status: status))
        }
        
    }
    
    
    

}
