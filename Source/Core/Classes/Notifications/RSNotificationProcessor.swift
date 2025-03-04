//
//  RSNotificationProcessor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import UserNotifications
import Gloss

public protocol RSNotificationProcessor {
    func supportsType(type: String) -> Bool
    func shouldUpdate(notification: RSNotification, state: RSState, lastState: RSState) -> Bool
    func generateNotificationRequest(notification: RSNotification, state: RSState, lastState: RSState) -> UNNotificationRequest?
    func identifierFilter(notification: RSNotification) -> (String) -> Bool
    func shouldCancelFilter(notification: RSNotification, state: RSState) -> (String) -> Bool
    func nextTriggerDate(notification: RSNotification, state: RSState) -> Date?
}
