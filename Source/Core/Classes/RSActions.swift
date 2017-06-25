//
//  RSActions.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

public struct AddStateValueAction: Action {
    let stateValue: RSStateValue
}
public struct AddMeasureAction: Action {
    let measure: RSMeasure
}

public struct AddActivityAction: Action {
    let activity: RSActivity
}

public struct QueueActivityAction: Action {
    let uuid: UUID
    let activityID: String
}

public struct PresentActivityAction: Action {
    let uuid: UUID
    let activityID: String
}

public struct DismissActivityAction: Action {
    let uuid: UUID
    let activityID: String
}

public struct RSSendResultToServerAction: Action {
    let value: ValueConvertible
}

struct SetValueInProtectedStorage: Action {
    let key: String
    let value: NSObject?
}

struct SetValueInUnprotectedStorage: Action {
    let key: String
    let value: NSObject?
}

