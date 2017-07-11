//
//  RSActions.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor

public struct AddStateValueAction: Action {
    let stateValue: RSStateValue
}

public struct AddConstantValueAction: Action {
    let constantValue: RSConstantValue
}

public struct AddFunctionValueAction: Action {
    let functionValue: RSFunctionValue
}

public struct RegisterFunctionAction: Action {
    let identifier: String
    let function: () -> AnyObject?
}

public struct UnregisterFunctionAction: Action {
    let identifier: String
}

public struct AddMeasureAction: Action {
    let measure: RSMeasure
}

public struct AddActivityAction: Action {
    let activity: RSActivity
}

public struct AddLayoutAction: Action {
    let layout: RSLayout
}

public struct AddRouteAction: Action {
    let route: RSRoute
}

public struct QueueActivityAction: Action {
    let uuid: UUID
    let activityID: String
}

public struct DequeueActivityAction: Action {
    let uuid: UUID
}

public struct SetPresentedActivityAction: Action {
    let uuid: UUID
    let activityID: String
}

public struct ClearPresentedActivityAction: Action {}

public struct RSSendResultToServerAction: Action {
    let intermediateResult: RSRPIntermediateResult
}

public struct SetValueInProtectedStorage: Action {
    let key: String
    let value: NSObject?
}

public struct SetValueInUnprotectedStorage: Action {
    let key: String
    let value: NSObject?
}

public struct PresentActivityRequest: Action {
    let uuid: UUID
    let activityID: String
}

public struct PresentActivitySuccess: Action {
    let uuid: UUID
    let activityID: String
}

public struct PresentActivityFailure: Action {
    let uuid: UUID
    let activityID: String
}

public struct DismissActivityRequest: Action {
    let uuid: UUID
    let activityID: String
}

public struct DismissActivitySuccess: Action {
    let uuid: UUID
    let activityID: String
}

public struct DismissActivityFailure: Action {
    let uuid: UUID
    let activityID: String
}




