//
//  RSAnalyticsMiddleware.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/4/17.
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
import ReSwift
import ResearchSuiteResultsProcessor
import Gloss

public protocol RSAnalyticsMiddlewareDelegate {
    func logActivity(activityID: String, uuid: UUID, startTime: Date, endTime: Date, completed: Bool)
    func logNotificationInteraction(notificationID: String, timestamp: Date)
}

open class RSAnalyticsMiddleware: RSMiddlewareProvider {
    
    open static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware? {
        
        guard let analyticsDelegate = appDelegate as? RSAnalyticsMiddlewareDelegate else {
            return nil
        }
        
        return { dispatch, getState in
            return { next in
                return { action in
                    
                    if let logActivityAction = action as? LogActivityAction {
                        analyticsDelegate.logActivity(
                            activityID: logActivityAction.activityID,
                            uuid: logActivityAction.uuid,
                            startTime: logActivityAction.startTime,
                            endTime: logActivityAction.endTime,
                            completed: logActivityAction.completed
                        )
                    }
                    else if let logNotificationAction = action as? LogNotificationAction {
                        analyticsDelegate.logNotificationInteraction(
                            notificationID: logNotificationAction.notificationID,
                            timestamp: logNotificationAction.date
                        )
                    }
                    return next(action)
                }
            }
        }
        
    }
    
}

