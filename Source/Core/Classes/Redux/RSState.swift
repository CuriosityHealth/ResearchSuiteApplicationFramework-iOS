//
//  RSState.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor
import ResearchKit
import UserNotifications

public final class RSState: NSObject, StateType {
    
//    public let protectedState: [String: NSObject]
//    public let unprotectedState: [String: NSObject]
    public let configurationCompleted: Bool
    
    //the actual state data
    public let applicationState: [String: NSObject]
    //metadata defined in the state config file
    public let stateValueMap: [String: RSStateValue]
    //mapping as to whether the application state value has been set
    //controls whether we use default value
    public let stateValueHasBeenSet: [String: NSObject]
    //metadata defined in the constants config file
    //static after config
    public let constantsMap: [String: RSConstantValue]
    //metadata defined in the constants config file
    //static after config
    public let functionsMap: [String: RSFunctionValue]
    //static after config
    public let measureMap: [String: RSMeasure]
    //static after config
    public let activityMap: [String: RSActivity]
    //static after config
    public let layoutMap: [String: RSLayout]
    //static after config
    public let routeMap: [String: RSRoute]
    //static after config
    public let routeIdentifiers: [String]
    
    public let activityQueue: [(UUID, String)]
    public let isPresenting: Bool
    public let isDismissing: Bool
    public let presentedActivity: (UUID, String, Date)?
    public let isRouting: Bool
    public let currentRoute: RSRoute?
    public let resultsProcessorBackEndMap: [String: RSRPBackEnd]
    
    //notifications
    public let pendingNotifications: [UNNotificationRequest]?
    public let isFetchingNotifications: Bool
    public let lastFetchTime: Date?
    //static after config
    public let notifications: [RSNotification]
    
    //location
    public let isRequestingLocationAuthorization: Bool
    public let locationAuthorizationStatus: CLAuthorizationStatus
    public let isFetchingLocation: Bool
    public let isLocationMonitoringEnabled: Bool?
    public let isVisitMonitoringEnabled: Bool?
    
    //passcode stuff
    public let isPresentingPasscode: Bool
    public let passcodeViewController: ORKPasscodeViewController?
    public let isDismissingPasscode: Bool
    
    //sign out
    public let signOutRequested: Bool
    
    public let preventSleep: Bool
    
    public init(configurationCompleted: Bool = false,
                applicationState: [String: NSObject] = [:],
                stateValueMap: [String: RSStateValue] = [:],
                stateValueHasBeenSet: [String: NSObject] = [:],
                constantsMap: [String: RSConstantValue] = [:],
                functionsMap: [String: RSFunctionValue] = [:],
                measureMap: [String: RSMeasure] = [:],
                activityMap: [String: RSActivity] = [:],
                layoutMap: [String: RSLayout] = [:],
                routeMap: [String: RSRoute] = [:],
                routeIdentifiers: [String] = [],
                activityQueue:[(UUID, String)] = [],
                isPresenting: Bool = false,
                isDismissing: Bool = false,
                presentedActivity: (UUID, String, Date)? = nil,
                isRouting: Bool = false,
                currentRoute: RSRoute? = nil,
                resultsProcessorBackEndMap: [String: RSRPBackEnd] = [:],
                pendingNotifications: [UNNotificationRequest]? = nil,
                isFetchingNotifications: Bool = false,
                lastFetchTime: Date? = nil,
                notifications: [RSNotification] = [],
                isRequestingLocationAuthorization: Bool = false,
                locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined,
                isFetchingLocation: Bool = false,
                isLocationMonitoringEnabled: Bool? = nil,
                isVisitMonitoringEnabled: Bool? = nil,
                isPresentingPasscode: Bool = false,
                passcodeViewController: ORKPasscodeViewController? = nil,
                isDismissingPasscode: Bool = false,
                signOutRequested: Bool = false,
                preventSleep: Bool = false
        ) {
        
        self.configurationCompleted = configurationCompleted
        self.applicationState = applicationState
        self.stateValueMap = stateValueMap
        self.stateValueHasBeenSet = stateValueHasBeenSet
        self.constantsMap = constantsMap
        self.functionsMap = functionsMap
        self.measureMap = measureMap
        self.activityMap = activityMap
        self.layoutMap = layoutMap
        self.routeMap = routeMap
        self.routeIdentifiers = routeIdentifiers
        self.activityQueue = activityQueue
        self.isPresenting = isPresenting
        self.isDismissing = isDismissing
        self.presentedActivity = presentedActivity
        self.isRouting = isRouting
        self.currentRoute = currentRoute
        self.resultsProcessorBackEndMap = resultsProcessorBackEndMap
        self.pendingNotifications = pendingNotifications
        self.isFetchingNotifications = isFetchingNotifications
        self.lastFetchTime = lastFetchTime
        self.notifications = notifications
        self.isRequestingLocationAuthorization = isRequestingLocationAuthorization
        self.locationAuthorizationStatus = locationAuthorizationStatus
        self.isFetchingLocation = isFetchingLocation
        self.isPresentingPasscode = isPresentingPasscode
        self.isLocationMonitoringEnabled = isLocationMonitoringEnabled
        self.isVisitMonitoringEnabled = isVisitMonitoringEnabled
        self.passcodeViewController = passcodeViewController
        self.isDismissingPasscode = isDismissingPasscode
        self.signOutRequested = signOutRequested
        self.preventSleep = preventSleep
    }
    
    static func newState(
        fromState: RSState,
        configurationCompleted: Bool? = nil,
        applicationState: [String: NSObject]? = nil,
        stateValueMap: [String: RSStateValue]? = nil,
        stateValueHasBeenSet: [String: NSObject]? = nil,
        constantsMap: [String: RSConstantValue]? = nil,
        functionsMap: [String: RSFunctionValue]? = nil,
        measureMap: [String: RSMeasure]? = nil,
        activityMap: [String: RSActivity]? = nil,
        layoutMap: [String: RSLayout]? = nil,
        routeMap: [String: RSRoute]? = nil,
        routeIdentifiers: [String]? = nil,
        activityQueue: [(UUID, String)]? = nil,
        isPresenting: Bool? = nil,
        isDismissing: Bool? = nil,
        presentedActivity: ((UUID, String, Date)?)? = nil,
        isRouting: Bool? = nil,
        currentRoute: RSRoute?? = nil,
        resultsProcessorBackEndMap: [String: RSRPBackEnd]? = nil,
        pendingNotifications: ([UNNotificationRequest]?)? = nil,
        isFetchingNotifications: Bool? = nil,
        lastFetchTime: Date?? = nil,
        notifications: [RSNotification]? = nil,
        isRequestingLocationAuthorization: Bool? = nil,
        locationAuthorizationStatus: CLAuthorizationStatus? = nil,
        isFetchingLocation: Bool? = nil,
        isPresentingPasscode: Bool? = nil,
        isLocationMonitoringEnabled: Bool?? = nil,
        isVisitMonitoringEnabled: Bool?? = nil,
        passcodeViewController: ORKPasscodeViewController?? = nil,
        isDismissingPasscode: Bool? = nil,
        signOutRequested: Bool? = nil,
        preventSleep: Bool? = nil
        ) -> RSState {
        
        return RSState(
            configurationCompleted: configurationCompleted ?? fromState.configurationCompleted,
            applicationState: applicationState ?? fromState.applicationState,
            stateValueMap: stateValueMap ?? fromState.stateValueMap,
            stateValueHasBeenSet: stateValueHasBeenSet ?? fromState.stateValueHasBeenSet,
            constantsMap: constantsMap ?? fromState.constantsMap,
            functionsMap: functionsMap ?? fromState.functionsMap,
            measureMap: measureMap ?? fromState.measureMap,
            activityMap: activityMap ?? fromState.activityMap,
            layoutMap: layoutMap ?? fromState.layoutMap,
            routeMap: routeMap ?? fromState.routeMap,
            routeIdentifiers: routeIdentifiers ?? fromState.routeIdentifiers,
            activityQueue: activityQueue ?? fromState.activityQueue,
            isPresenting: isPresenting ?? fromState.isPresenting,
            isDismissing: isDismissing ?? fromState.isDismissing,
            presentedActivity: presentedActivity ?? fromState.presentedActivity,
            isRouting: isRouting ?? fromState.isRouting,
            currentRoute: currentRoute ?? fromState.currentRoute,
            resultsProcessorBackEndMap: resultsProcessorBackEndMap ?? fromState.resultsProcessorBackEndMap,
            pendingNotifications: pendingNotifications ?? fromState.pendingNotifications,
            isFetchingNotifications: isFetchingNotifications ?? fromState.isFetchingNotifications,
            lastFetchTime: lastFetchTime ?? fromState.lastFetchTime,
            notifications: notifications ?? fromState.notifications,
            isRequestingLocationAuthorization: isRequestingLocationAuthorization ?? fromState.isRequestingLocationAuthorization,
            locationAuthorizationStatus: locationAuthorizationStatus ?? fromState.locationAuthorizationStatus,
            isFetchingLocation: isFetchingLocation ?? fromState.isFetchingLocation,
            isLocationMonitoringEnabled: isLocationMonitoringEnabled ?? fromState.isLocationMonitoringEnabled,
            isVisitMonitoringEnabled: isVisitMonitoringEnabled ?? fromState.isVisitMonitoringEnabled,
            isPresentingPasscode: isPresentingPasscode ?? fromState.isPresentingPasscode,
            passcodeViewController: passcodeViewController ?? fromState.passcodeViewController,
            isDismissingPasscode: isDismissingPasscode ?? fromState.isDismissingPasscode,
            signOutRequested: signOutRequested ?? fromState.signOutRequested,
            preventSleep: preventSleep ?? fromState.preventSleep
        )
    }
    
    open class func empty() -> Self {
        return self.init()
    }
    
    open override var description: String {
        return
            "\n\tapplicationState: \(self.applicationState)" +
//            "\n\tstateValueHasBeenSet: \(self.stateValueHasBeenSet)" +
//            "\n\tconstants: \(self.constantsMap)" +
            "\n\tactivityQueue: \(self.activityQueue)" +
        "\n\tpresentedActivity: \(self.presentedActivity)" +
        "\n\tpresentedPasscode: \(self.passcodeViewController)" +
        "\n\tpendingNotifications: \(self.pendingNotifications?.map{ $0.identifier }.sorted())"
        
    }
    
}
