//
//  RSNotificationProcessor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
