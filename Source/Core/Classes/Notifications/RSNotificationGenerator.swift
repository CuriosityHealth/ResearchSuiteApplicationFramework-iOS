//
//  RSNotificationGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//

import UIKit
import UserNotifications
import Gloss

public protocol RSNotificationGenerator {
    func supportsType(type: String) -> Bool
    func shouldUpdate(jsonObject: JSON, state: RSState, lastState: RSState) -> Bool
    func generateNotificationRequest(jsonObject: JSON, state: RSState, lastState: RSState) -> UNNotificationRequest?
    func identifierFilter(jsonObject: JSON, identifiers: [String]) -> [String]
}
