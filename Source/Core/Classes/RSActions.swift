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
import ResearchKit

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
    let backendIdentifier: String
    let intermediateResult: RSRPIntermediateResult
}

public struct SetValueInState: Action {
    let key: String
    let value: NSObject?
}

public struct ResetValueInState: Action {
    let key: String
}

public struct ResetStateManagerRequest: Action {
    let identifier: String
}

public struct ResetStateManagerSuccess: Action {
    let identifier: String
}

public struct ResetStateManagerFailure: Action {
    let identifier: String
}

//public struct SetValueInProtectedStorage: Action {
//    let key: String
//    let value: NSObject?
//}
//
//public struct SetValueInUnprotectedStorage: Action {
//    let key: String
//    let value: NSObject?
//}

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

public struct ChangeRouteRequest: Action {
    let route: RSRoute
}

public struct ChangeRouteSuccess: Action {
    let route: RSRoute
}

public struct ChangeRouteFailure: Action {
    let route: RSRoute
}

public struct RegisterResultsProcessorBackEndAction: Action {
    let identifier: String
    let backEnd: RSRPBackEnd
}

public struct UnregisterResultsProcessorBackEndAction: Action {
    let identifier: String
}

public struct CompleteConfiguration: Action {
}

public struct PresentPasscodeRequest: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}

public struct PresentPasscodeSuccess: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}

public struct PresentPasscodeFailure: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}

public struct DismissPasscodeRequest: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}

public struct DismissPasscodeSuccess: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}

public struct DismissPasscodeFailure: Action {
    let uuid: UUID
    let passcodeViewController: ORKPasscodeViewController
}



