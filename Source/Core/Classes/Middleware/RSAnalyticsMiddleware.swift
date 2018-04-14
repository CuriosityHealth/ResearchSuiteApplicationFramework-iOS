//
//  RSAnalyticsMiddleware.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/4/17.
//

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
                    
                    if let encodableAction = action as? JSONEncodable,
                        let json = encodableAction.toJSON() {
                        debugPrint(json)
                    }
                    
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

