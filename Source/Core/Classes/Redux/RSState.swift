//
//  RSState.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor
import ResearchKit
import UserNotifications
import Gloss

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
    public let definedActionsMap: [String: RSDefinedAction]
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
    
    public let activityQueue: [(UUID, String, JSON?)]
    public let isPresenting: Bool
    public let isDismissing: Bool
    public let presentedActivity: (UUID, String, Date)?
    
    public let isRouting: Bool
    
    public let pathHistory:[String]
    public let currentPath: String?
    public let pathChangeRequestQueue: [(UUID, String, Bool)]
//    public let requestedPath: String?
//    public let forceReroute: Bool
    
//    public let resultsProcessorBackEndMap: [String: RSRPBackEnd]
    public let dataSourceMap: [String: RSDataSource]
    public let dataSinkMap: [String: RSDataSink]
    
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
    public let reloadConfigRequested: Bool
    
    public let preventSleep: Bool
    
    public init(configurationCompleted: Bool = false,
                applicationState: [String: NSObject] = [:],
                stateValueMap: [String: RSStateValue] = [:],
                stateValueHasBeenSet: [String: NSObject] = [:],
                constantsMap: [String: RSConstantValue] = [:],
                functionsMap: [String: RSFunctionValue] = [:],
                definedActionsMap: [String: RSDefinedAction] = [:],
                measureMap: [String: RSMeasure] = [:],
                activityMap: [String: RSActivity] = [:],
                layoutMap: [String: RSLayout] = [:],
                routeMap: [String: RSRoute] = [:],
                routeIdentifiers: [String] = [],
                activityQueue:[(UUID, String, JSON?)] = [],
                isPresenting: Bool = false,
                isDismissing: Bool = false,
                presentedActivity: (UUID, String, Date)? = nil,
                isRouting: Bool = false,
                pathHistory: [String] = [],
                currentPath: String? = nil,
                pathChangeRequestQueue: [(UUID, String, Bool)] = [],
                dataSourceMap: [String: RSDataSource] = [:],
                dataSinkMap: [String: RSDataSink] = [:],
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
                reloadConfigRequested: Bool = false,
                preventSleep: Bool = false
        ) {
        
        self.configurationCompleted = configurationCompleted
        self.applicationState = applicationState
        self.stateValueMap = stateValueMap
        self.stateValueHasBeenSet = stateValueHasBeenSet
        self.constantsMap = constantsMap
        self.functionsMap = functionsMap
        self.definedActionsMap = definedActionsMap
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
//        self.currentRoute = currentRoute
        self.pathHistory = pathHistory
        self.currentPath = currentPath
        self.pathChangeRequestQueue = pathChangeRequestQueue
//        self.resultsProcessorBackEndMap = resultsProcessorBackEndMap
        self.dataSourceMap = dataSourceMap
        self.dataSinkMap = dataSinkMap
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
        self.reloadConfigRequested = reloadConfigRequested
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
        definedActionsMap: [String: RSDefinedAction]? = nil,
        measureMap: [String: RSMeasure]? = nil,
        activityMap: [String: RSActivity]? = nil,
        layoutMap: [String: RSLayout]? = nil,
        routeMap: [String: RSRoute]? = nil,
        routeIdentifiers: [String]? = nil,
        activityQueue: [(UUID, String, JSON?)]? = nil,
        isPresenting: Bool? = nil,
        isDismissing: Bool? = nil,
        presentedActivity: ((UUID, String, Date)?)? = nil,
        isRouting: Bool? = nil,
        pathHistory: [String]? = nil,
        currentPath: String?? = nil,
        pathChangeRequestQueue: [(UUID, String, Bool)]? = nil,
        
        resultsProcessorBackEndMap: [String: RSRPBackEnd]? = nil,
        dataSourceMap: [String: RSDataSource]? = nil,
        dataSinkMap: [String: RSDataSink]? = nil,
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
        reloadConfigRequested: Bool? = nil,
        preventSleep: Bool? = nil
        ) -> RSState {
        
        return RSState(
            configurationCompleted: configurationCompleted ?? fromState.configurationCompleted,
            applicationState: applicationState ?? fromState.applicationState,
            stateValueMap: stateValueMap ?? fromState.stateValueMap,
            stateValueHasBeenSet: stateValueHasBeenSet ?? fromState.stateValueHasBeenSet,
            constantsMap: constantsMap ?? fromState.constantsMap,
            functionsMap: functionsMap ?? fromState.functionsMap,
            definedActionsMap: definedActionsMap ?? fromState.definedActionsMap,
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
            pathHistory: pathHistory ?? fromState.pathHistory,
            currentPath: currentPath ?? fromState.currentPath,
            pathChangeRequestQueue: pathChangeRequestQueue ?? fromState.pathChangeRequestQueue,
            dataSourceMap: dataSourceMap ?? fromState.dataSourceMap,
            dataSinkMap: dataSinkMap ?? fromState.dataSinkMap,
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
            reloadConfigRequested: reloadConfigRequested ?? fromState.reloadConfigRequested,
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
        "\n\tpendingNotifications: \(self.pendingNotifications?.map{ $0.identifier }.sorted())" +
        "\n\tcurrentPath: \(self.currentPath ?? "no path")"
        
    }
    
}
