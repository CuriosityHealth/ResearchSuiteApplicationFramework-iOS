//
//  RSNotificationProcessor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//

import UIKit
import UserNotifications
import Gloss

public protocol RSNotificationProcessor {
    func supportsType(type: String) -> Bool
    func shouldUpdate(notification: RSNotification, state: RSState, lastState: RSState) -> Bool
    func generateNotificationRequest(notification: RSNotification, state: RSState, lastState: RSState) -> UNNotificationRequest?
    func identifierFilter(notification: RSNotification, identifiers: [String]) -> [String]
}
