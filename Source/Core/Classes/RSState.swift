//
//  RSState.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift

public final class RSState: StateType {
    
    public let protectedState: [String: NSObject]
    public let unprotectedState: [String: NSObject]
    public let measureMap: [String: RSMeasure]
    public let activityMap: [String: RSActivity]
    
    public init(protectedState: [String: NSObject] = [:],
                unprotectedState: [String: NSObject] = [:],
                measureMap: [String: RSMeasure] = [:],
                activityMap: [String: RSActivity] = [:]
        ) {
        
        self.protectedState = protectedState
        self.unprotectedState = unprotectedState
        self.measureMap = measureMap
        self.activityMap = activityMap
    }
    
    static func newState(
        fromState: RSState,
        protectedState: [String: NSObject]? = nil,
        unprotectedState: [String: NSObject]? = nil,
        measureMap: [String: RSMeasure]? = nil,
        activityMap: [String: RSActivity]? = nil
        ) -> RSState {
        
        return RSState(
            protectedState: protectedState ?? fromState.protectedState,
            unprotectedState: unprotectedState ?? fromState.unprotectedState,
            measureMap: measureMap ?? fromState.measureMap,
            activityMap: activityMap ?? fromState.activityMap
        )
    }
    
    open class func empty() -> Self {
        return self.init()
    }
    
}
