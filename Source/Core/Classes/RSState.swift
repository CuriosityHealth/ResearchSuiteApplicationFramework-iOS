//
//  RSState.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift

public final class RSState: NSObject, StateType {
    
    public let protectedState: [String: NSObject]
    public let unprotectedState: [String: NSObject]
    public let stateValueMap: [String: RSStateValue]
    public let stateValueHasBeenSet: [String: NSObject]
    public let constantsMap: [String: RSConstantValue]
    public let functionsMap: [String: RSFunctionValue]
    public let measureMap: [String: RSMeasure]
    public let activityMap: [String: RSActivity]
    public let activityQueue: [(UUID, String)]
    public let presentedActivity: (UUID, String)?
    
    public init(protectedState: [String: NSObject] = [:],
                unprotectedState: [String: NSObject] = [:],
                stateValueMap: [String: RSStateValue] = [:],
                stateValueHasBeenSet: [String: NSObject] = [:],
                constantsMap: [String: RSConstantValue] = [:],
                functionsMap: [String: RSFunctionValue] = [:],
                measureMap: [String: RSMeasure] = [:],
                activityMap: [String: RSActivity] = [:],
                activityQueue:[(UUID, String)] = [],
                presentedActivity: (UUID, String)? = nil
        ) {
        
        self.protectedState = protectedState
        self.unprotectedState = unprotectedState
        self.stateValueMap = stateValueMap
        self.stateValueHasBeenSet = stateValueHasBeenSet
        self.constantsMap = constantsMap
        self.functionsMap = functionsMap
        self.measureMap = measureMap
        self.activityMap = activityMap
        self.activityQueue = activityQueue
        self.presentedActivity = presentedActivity
    }
    
    static func newState(
        fromState: RSState,
        protectedState: [String: NSObject]? = nil,
        unprotectedState: [String: NSObject]? = nil,
        stateValueMap: [String: RSStateValue]? = nil,
        stateValueHasBeenSet: [String: NSObject]? = nil,
        constantsMap: [String: RSConstantValue]? = nil,
        functionsMap: [String: RSFunctionValue]? = nil,
        measureMap: [String: RSMeasure]? = nil,
        activityMap: [String: RSActivity]? = nil,
        activityQueue: [(UUID, String)]? = nil,
        presentedActivity: ((UUID, String)?)? = nil
        ) -> RSState {
        
        return RSState(
            protectedState: protectedState ?? fromState.protectedState,
            unprotectedState: unprotectedState ?? fromState.unprotectedState,
            stateValueMap: stateValueMap ?? fromState.stateValueMap,
            stateValueHasBeenSet: stateValueHasBeenSet ?? fromState.stateValueHasBeenSet,
            constantsMap: constantsMap ?? fromState.constantsMap,
            functionsMap: functionsMap ?? fromState.functionsMap,
            measureMap: measureMap ?? fromState.measureMap,
            activityMap: activityMap ?? fromState.activityMap,
            activityQueue: activityQueue ?? fromState.activityQueue,
            presentedActivity: presentedActivity ?? fromState.presentedActivity
        )
    }
    
    open class func empty() -> Self {
        return self.init()
    }
    
    open override var description: String {
        return "\n\tprotectedState: \(self.protectedState)" +
            "\n\tunprotectedState: \(self.unprotectedState)" +
            "\n\tconstants: \(self.constantsMap)" +
            "\n\tactivityQueue: \(self.activityQueue)" +
        "\n\tpresentedActivity: \(self.presentedActivity)"
        
    }
    
}
