//
//  RSActions.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor
import ResearchKit
import UserNotifications
import Gloss

public protocol RSAction: Action, JSONEncodable {
    var actionType: String { get }
}

extension RSAction {
    public var actionType: String {
        return "\(type(of: self))"
    }
}

public struct AddStateValueAction: RSAction {

    public func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.actionType,
            "stateValue" ~~> self.stateValue
            ])
    }
    
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
    let function: (RSState) -> AnyObject?
}

public struct UnregisterFunctionAction: Action {
    let identifier: String
}

public struct AddDefinedAction: Action {
    let definedAction: RSDefinedAction
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

public struct FlushActivityQueue: Action {}

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
    let presentationTime: Date
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

public struct ChangePathRequest: Action {
    let uuid: UUID
    let requestedPath: String
    let forceReroute: Bool
}

public struct RoutingStarted: Action {
    let uuid: UUID
}

public struct ChangePathSuccess: Action {
    let uuid: UUID
    let requestedPath: String
    let finalPath: String
}

public struct ChangePathFailure: Action {
    let uuid: UUID
    let requestedPath: String
    let finalPath: String
    let error: Error
}

//public struct ChangeRouteRequest: Action {
//    let route: RSRoute
//}
//
//public struct ChangeRouteSuccess: Action {
//    let route: RSRoute
//}
//
//public struct ChangeRouteFailure: Action {
//    let route: RSRoute
//}

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

public struct SignOutRequest: Action {
    
}

public struct SetPreventSleep: Action {
    let preventSleep: Bool
}

//Notifications
public struct FetchPendingNotificationsRequest: Action {
    
}

public struct FetchPendingNotificationsSuccess: Action {
    let pendingNotifications: [UNNotificationRequest]
    let fetchTime: Date
}

public struct FetchPendingNotificationsFailure: Action {

}

public struct AddNotificationAction: Action {
    let notification: RSNotification
}

//Location
public struct FetchCurrentLocationRequest: Action {
    
}

public struct FetchCurrentLocationSuccess: Action {
    let locations: [CLLocation]
}

public struct FetchCurrentLocationFailure: Action {
    let error: Error
}

public struct SetLocationAuthorizationStatus: Action {
    let status: CLAuthorizationStatus
}

public struct UpdateLocationAuthorizationStatusRequest: Action {
    let always: Bool
}

public struct UpdateLocationAuthorizationStatusSuccess: Action {
    let status: CLAuthorizationStatus
}

public struct UpdateLocationAuthorizationStatusFailure: Action {
    
}

public struct SetLocationMonitoringEnabled: Action {
    let enabled: Bool
}

public struct SetVisitMonitoringEnabled: Action {
    let enabled: Bool
}



//Analytics Stuff
public struct LogActivityAction: Action {
    let activityID: String
    let uuid: UUID
    let startTime: Date
    let endTime: Date
    let completed: Bool
}

public struct LogNotificationAction: Action {
    let notificationID: String
    let date: Date
}





