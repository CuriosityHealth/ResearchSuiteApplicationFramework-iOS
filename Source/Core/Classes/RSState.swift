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

public final class RSState: NSObject, StateType {
    
//    public let protectedState: [String: NSObject]
//    public let unprotectedState: [String: NSObject]
    public let applicationState: [String: NSObject]
    public let stateValueMap: [String: RSStateValue]
    public let stateValueHasBeenSet: [String: NSObject]
    public let constantsMap: [String: RSConstantValue]
    public let functionsMap: [String: RSFunctionValue]
    public let measureMap: [String: RSMeasure]
    public let activityMap: [String: RSActivity]
    public let layoutMap: [String: RSLayout]
    public let routeMap: [String: RSRoute]
    public let routeIdentifiers: [String]
    public let activityQueue: [(UUID, String)]
    public let isPresenting: Bool
    public let isDismissing: Bool
    public let presentedActivity: (UUID, String)?
    public let isRouting: Bool
    public let currentRoute: RSRoute?
    public let resultsProcessorBackEndMap: [String: RSRPBackEnd]
    
    public init(applicationState: [String: NSObject] = [:],
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
                presentedActivity: (UUID, String)? = nil,
                isRouting: Bool = false,
                currentRoute: RSRoute? = nil,
                resultsProcessorBackEndMap: [String: RSRPBackEnd] = [:]
        ) {
        
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
    }
    
    static func newState(
        fromState: RSState,
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
        presentedActivity: ((UUID, String)?)? = nil,
        isRouting: Bool? = nil,
        currentRoute: RSRoute?? = nil,
        resultsProcessorBackEndMap: [String: RSRPBackEnd]? = nil
        ) -> RSState {
        
        return RSState(
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
            resultsProcessorBackEndMap: resultsProcessorBackEndMap ?? fromState.resultsProcessorBackEndMap
        )
    }
    
    open class func empty() -> Self {
        return self.init()
    }
    
    open override var description: String {
        return "\n\tapplicationState: \(self.applicationState)" +
            "\n\tstateValueHasBeenSet: \(self.stateValueHasBeenSet)" +
            "\n\tconstants: \(self.constantsMap)" +
            "\n\tactivityQueue: \(self.activityQueue)" +
        "\n\tpresentedActivity: \(self.presentedActivity)"
        
    }
    
}
