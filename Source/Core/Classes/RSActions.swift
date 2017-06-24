//
//  RSActions.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

public struct AddMeasureAction: Action {
    let measure: RSMeasure
}

public struct AddActivityAction: Action {
    let activity: RSActivity
}

public struct RSSendResultToServerAction: Action {
    let value: ValueConvertible
}


