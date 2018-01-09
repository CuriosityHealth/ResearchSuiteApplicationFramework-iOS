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
    
    static let kSource = "RSLocationManager"
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
        guard let regionGroups = self.config.regionMonitoringConfig?.regionGroups else {
            return
        }
        
        let monitoredRegions = Array(self.locationManager.monitoredRegions)
        debugPrint("\(monitoredRegions.map { $0.identifier }) enabled regions")
        regionGroups.forEach { self.processRegionGroup(regionGroup: $0, state: state, lastState: lastState, monitoredRegions: monitoredRegions) }
    }
    
//    private func shouldUpdateRegionGroup(regionGroup: RSRegionGroup, state: RSState, lastState: RSState, monitoredRegions: [CLRegion]) -> Bool {
//        //we should refresh the region under two circumstances
//        //first, if it is not yet being monitored
//        //otherwise, if monitored values have changed
//        let monitoredRegionIdentifiers = monitoredRegions.map { $0.identifier }
//        if !monitoredRegionIdentifiers.contains(region.identifier) {
//            return true
//        }
//        else {
//            //otherwise, check monitored values to see if they changed between state and last state
//            return region.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
//                return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
//            }
//        }
//    }
    
    private func regionListToMap(regions: [CLRegion]) -> [String: CLRegion] {
        var regionMap: [String: CLRegion] = [:]
        regions.forEach { regionMap[$0.identifier] = $0 }
        return regionMap
    }
    
    private func prefixFor(regionGroup: RSRegionGroup) -> String {
        return "\(regionGroup.identifier)."
    }
    
    private func processRegionGroup(regionGroup: RSRegionGroup, state: RSState, lastState: RSState, monitoredRegions: [CLRegion]) {
        
        let monitoredRegionsMap = self.regionListToMap(regions: monitoredRegions)
        
        let groupEnabled: Bool = {
            //check for predicate and evaluate
            //if predicate exists and evaluates false, do not execute action
            if let predicate = regionGroup.predicate {
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
        
        //if region SHOULD NOT be enabled, disable all regions in the group
        if !groupEnabled {
            
            let enabledGroupRegions:[String] = monitoredRegionsMap.keys.filter { $0.starts(with: self.prefixFor(regionGroup: regionGroup)) }
            enabledGroupRegions.forEach { regionID in
                guard let region = monitoredRegionsMap[regionID] else {
                    return
                }
                self.locationManager.stopMonitoring(for: region)
            }
            
            return
            
        }
        else {
            
            let regions: [CLRegion] = {
                
                if let regions = regionGroup.regions {
                    return RSValueManager.processValue(jsonObject: regions, state: state, context: [:])?.evaluate() as? [CLRegion] ?? []
                }
                else if let region = regionGroup.region {
                    return [RSValueManager.processValue(jsonObject: region, state: state, context: [:])?.evaluate() as? CLRegion].flatMap { $0 }
                }
                else {
                    return []
                }
                
            }()
            
            let expectedRegions: [CLRegion] = regions.flatMap { region in
                
                if let circularRegion = region as? CLCircularRegion {
                    return CLCircularRegion(center: circularRegion.center, radius: circularRegion.radius, identifier: "\(self.prefixFor(regionGroup: regionGroup))\(circularRegion.identifier)")
                }
                else if let _ = region as? CLBeaconRegion {
                    assertionFailure("Beacons not yet supported")
                    return nil
                }
                else {
                    return nil
                }
                
            }
            
            let expectedRegionsMap = self.regionListToMap(regions: expectedRegions)
            
            //if group is enabled, we need to determine if there are any regions in the group that:
            // should start being monitored
            // should stop being monitored
            // should be updated
            
            let regionsToStopMonitoring = self.regionsToStopMonitoring(monitoredRegionsMap: monitoredRegionsMap, expectedRegionsMap: expectedRegionsMap)
            let regionsToStartMonitoringOrUpdate = self.regionsToStartMonitoring(monitoredRegionsMap: monitoredRegionsMap, expectedRegionsMap: expectedRegionsMap)
                .union(self.regionsToUpdateMonitoring(monitoredRegionsMap: monitoredRegionsMap, expectedRegionsMap: expectedRegionsMap))
            
            regionsToStopMonitoring.forEach { region in
                self.locationManager.stopMonitoring(for: region)
            }
            
            regionsToStartMonitoringOrUpdate.forEach { region in
                debugPrint("starting to monitor region: \(region.identifier)")
                self.locationManager.startMonitoring(for: region)
                self.fetchState(region: region, completion: { (region, state) in
                    debugPrint("\(region.identifier): \(region): initially in \(state.rawValue)")
                })
            }
        }
        
    }
    
    private func regionsToStartMonitoring(monitoredRegionsMap: [String: CLRegion], expectedRegionsMap: [String: CLRegion]) -> Set<CLRegion> {
        
        let enabledSet = Set(monitoredRegionsMap.keys)
        let shouldBeEnabledSet = Set(expectedRegionsMap.keys)
        return Set(shouldBeEnabledSet.subtracting(enabledSet).flatMap { identifier in
            return expectedRegionsMap[identifier]
        })
    }
    
    private func regionsToStopMonitoring(monitoredRegionsMap: [String: CLRegion], expectedRegionsMap: [String: CLRegion]) -> Set<CLRegion> {
        
        let enabledSet = Set(monitoredRegionsMap.keys)
        let shouldBeEnabledSet = Set(expectedRegionsMap.keys)
        return Set(enabledSet.subtracting(shouldBeEnabledSet).flatMap { identifier in
            return monitoredRegionsMap[identifier]
        })
    }
    
    //by default, accurate to 5th decimal place, or 1.1 meter
    //https://gis.stackexchange.com/questions/8650/measuring-accuracy-of-latitude-and-longitude
    private func coordiatesEquivalent(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D, epsilon: Double = 0.00001) -> Bool {
        
        return abs(coord1.latitude - coord2.latitude) < epsilon &&
            abs(coord1.longitude - coord2.longitude) < epsilon
        
    }
    private func regionsEqual(_ region1: CLRegion, _ region2: CLRegion) -> Bool {
        
        guard let circularRegion1 = region1 as? CLCircularRegion,
            let circularRegion2 = region2 as? CLCircularRegion else {
                assertionFailure("Beacons not yet supported")
                return false
        }
        
        return circularRegion1.identifier == circularRegion2.identifier &&
            abs(circularRegion1.radius - circularRegion2.radius) < 1.0 &&
            self.coordiatesEquivalent(circularRegion1.center, circularRegion2.center)
        
    }
    
    private func regionsToUpdateMonitoring(monitoredRegionsMap: [String: CLRegion], expectedRegionsMap: [String: CLRegion]) -> Set<CLRegion> {

        let enabledSet = Set(monitoredRegionsMap.keys)
        let shouldBeEnabledSet = Set(expectedRegionsMap.keys)
        let intersetingIdentifiers = enabledSet.intersection(shouldBeEnabledSet)
        
        let regionsToUpdate = intersetingIdentifiers.filter { identifier in
            
            guard let expectedRegion = expectedRegionsMap[identifier],
                let monitoredRegion = monitoredRegionsMap[identifier] else {
                    return true
            }
            
            return !self.regionsEqual(expectedRegion, monitoredRegion)
            
            }.flatMap { identifier in
                return expectedRegionsMap[identifier]
        }
        
        return Set(regionsToUpdate)
    }
    
    
    public func fetchCurrentLocation(completion: @escaping FetchLocationCompletion) {
        self.fetchLocationCompletion = completion
        self.locationManager.requestLocation()
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
    
    private func regionGroup(forRegion: CLRegion) -> RSRegionGroup? {
        return self.config.regionMonitoringConfig?.regionGroups.first(where: { forRegion.identifier.starts(with: self.prefixFor(regionGroup: $0)) })
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let store = self.store,
            let regionGroup = self.regionGroup(forRegion: region),
            let actions = regionGroup.onEnterActions else {
                return
        }
        
        let regionTransitionEvent = RSRegionTransitionEvent(
            regionGroup: regionGroup,
            region: region,
            transition: .enter,
            source: RSLocationManager.kSource,
            uuid: UUID(),
            timestamp: Date()
        )
        
        RSActionManager.processActions(actions: actions, context: ["sensedRegionTransitionEvent": regionTransitionEvent], store: store)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let store = self.store,
            let regionGroup = self.regionGroup(forRegion: region),
            let actions = regionGroup.onExitActions else {
                return
        }
        
        let regionTransitionEvent = RSRegionTransitionEvent(
            regionGroup: regionGroup,
            region: region,
            transition: .exit,
            source: RSLocationManager.kSource,
            uuid: UUID(),
            timestamp: Date()
        )
        
        RSActionManager.processActions(actions: actions, context: ["sensedRegionTransitionEvent": regionTransitionEvent], store: store)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        guard let store = self.store,
            let regionGroup = self.regionGroup(forRegion: region) else {
                return
        }
        
        if let completion = self.fetchRegionStateCompletionMap[region.identifier] {
            completion(region, state)
            self.fetchRegionStateCompletionMap[region.identifier] = nil
        }
        
        guard let actions = regionGroup.onStateActions else {
            return
        }
        
        let state: RSRegionTransitionEvent.Transition = {
            switch state {
            case .inside:
                return .startedInside
            case .outside:
                return .startedOutside
            default:
                return .startedUnknown
            }
        }()
        
        let regionTransitionEvent = RSRegionTransitionEvent(
            regionGroup: regionGroup,
            region: region,
            transition: state,
            source: RSLocationManager.kSource,
            uuid: UUID(),
            timestamp: Date()
        )
        
        RSActionManager.processActions(actions: actions, context: ["sensedRegionTransitionEvent": regionTransitionEvent], store: store)
    }
    
    
    

}
