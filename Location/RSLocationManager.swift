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
    var lastState: RSState?
    
    let locationManager: CLLocationManager
    let config: RSLocationManagerConfiguration
    
    public typealias FetchLocationCompletion = ([CLLocation]?, Error?) -> ()
    var fetchLocationCompletion: FetchLocationCompletion?
    
    public typealias FetchRegionStateCompletion = (CLRegion, CLRegionState) -> ()
    var fetchRegionStateCompletionMap: [String:FetchRegionStateCompletion] = [:]
    
    public init(store: Store<RSState>, config: RSLocationManagerConfiguration) {
        self.store = store
        self.locationManager = CLLocationManager()
        self.config = config
        super.init()
        self.locationManager.delegate = self
    }
    
    public func stopMonitoringRegions() {
        self.locationManager.monitoredRegions.forEach { self.locationManager.stopMonitoring(for: $0) }
    }
    
    public func newState(state: RSState) {
        
        //check for notifications being enabled
        guard let lastState = self.lastState else {
            self.lastState = state
            return
        }
        
        self.lastState = state
        
        guard RSStateSelectors.isConfigurationCompleted(state) else {
            return
        }
        
        self.doRegionProcessing(state: state, lastState: lastState)
        
    }
    
    public func doRegionProcessing(state: RSState, lastState: RSState) {
        //check for proper authorization
        //for region monitoring, we need always authorization
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            return
        }
        
        //Possibly add a predicate for ALL regions
        guard let regions = self.config.regionMonitoringConfig?.regions else {
            return
        }
        
        let monitoredRegions = Array(self.locationManager.monitoredRegions)
        regions.forEach { self.processRegion(region: $0, state: state, lastState: lastState, monitoredRegions: monitoredRegions) }
    }
    
    private func shouldUpdateRegion(region: RSRegion, state: RSState, lastState: RSState, monitoredRegions: [CLRegion]) -> Bool {
        //we should refresh the region under two circumstances
        //first, if it is not yet being monitored
        //otherwise, if monitored values have changed
        let monitoredRegionIdentifiers = monitoredRegions.map { $0.identifier }
        if !monitoredRegionIdentifiers.contains(region.identifier) {
            return true
        }
        else {
            //otherwise, check monitored values to see if they changed between state and last state
            return region.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
                return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
            }
        }
    }
    
    private func processRegion(region: RSRegion, state: RSState, lastState: RSState, monitoredRegions: [CLRegion]) {
        
        let enabledRegionIdentifiers: [String] = monitoredRegions.map { $0.identifier }
        
        let enabled: Bool = {
            //check for predicate and evaluate
            //if predicate exists and evaluates false, do not execute action
            if let predicate = region.predicate {
                debugPrint(predicate)
                if RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:]) {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return true
            }
            
        }()
        
        //if region SHOULD NOT be enabled, find the region and stop monitoring
        if !enabled {
            if enabledRegionIdentifiers.contains(region.identifier),
                let cl_region = monitoredRegions.first(where: { $0.identifier == region.identifier }) {
                
                self.locationManager.stopMonitoring(for: cl_region)
                return
            }
            else {
                return
            }
            
        }
        else {
            //if region SHOULD be enabled,
            if self.shouldUpdateRegion(region: region, state: state, lastState: lastState, monitoredRegions: monitoredRegions),
                let cl_region = self.CLRegionForRegion(region: region, state: state) {
                self.locationManager.startMonitoring(for: cl_region)
                self.fetchState(region: cl_region, completion: { (region, state) in
                    
                    debugPrint("\(region.identifier): \(region): initially in \(state.rawValue)")
                    
                })
            }
            
            
        }
        
    }
    
    public func fetchCurrentLocation(completion: @escaping FetchLocationCompletion) {
        self.fetchLocationCompletion = completion
        self.locationManager.requestLocation()
    }
    
    public func CLRegionForRegion(region: RSRegion, state: RSState) -> CLRegion? {
        guard let radius = RSValueManager.processValue(jsonObject: region.radius, state: state, context: [:])?.evaluate() as? Double,
            let location = RSValueManager.processValue(jsonObject: region.location, state: state, context: [:])?.evaluate() as? CLLocation else {
            return nil
        }
        
        return CLCircularRegion(center: location.coordinate, radius: radius, identifier: region.identifier)
    }
    
    public func fetchState(region: CLRegion, completion: @escaping FetchRegionStateCompletion) {
        self.fetchRegionStateCompletionMap[region.identifier] = completion
        self.locationManager.requestState(for: region)
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
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let store = self.store,
            let suiteRegion: RSRegion = self.config.regionMonitoringConfig?.regions.first(where: { region.identifier == $0.identifier }),
            let actions = suiteRegion.onEnterActions else {
                return
        }
        
        RSActionManager.processActions(actions: actions, context: ["CLRegion": region, "RSRegion": suiteRegion], store: store)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let store = self.store,
            let suiteRegion: RSRegion = self.config.regionMonitoringConfig?.regions.first(where: { region.identifier == $0.identifier }),
            let actions = suiteRegion.onExitActions else {
                return
        }
        
        RSActionManager.processActions(actions: actions, context: ["CLRegion": region, "RSRegion": suiteRegion], store: store)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        guard let store = self.store,
            let suiteRegion: RSRegion = self.config.regionMonitoringConfig?.regions.first(where: { region.identifier == $0.identifier }) else {
                return
        }
        
        if let completion = self.fetchRegionStateCompletionMap[region.identifier] {
            completion(region, state)
            self.fetchRegionStateCompletionMap[region.identifier] = nil
        }
        
        guard let actions = suiteRegion.initialStateActions else {
            return
        }
        
        let stateString: String = {
            switch state {
            case .inside:
                return "inside"
            case .outside:
                return "outside"
            default:
                return "unknown"
            }
        }()
        
        RSActionManager.processActions(actions: actions, context: ["CLRegion": region, "RSRegion": suiteRegion, "state": stateString as NSString], store: store)
    }
    
    
    

}
