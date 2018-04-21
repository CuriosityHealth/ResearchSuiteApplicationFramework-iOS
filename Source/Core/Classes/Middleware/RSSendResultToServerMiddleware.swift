//
//  RSSendResultToServerMiddleware.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor

open class RSSendResultToServerMiddleware: RSMiddlewareProvider {
    
    open static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware? {
        return { dispatch, getState in
            return { next in
                return { action in
                    
                    if let sendResultAction = action as? RSSendResultToServerAction,
                        let state = getState() as? RSState,
                        let backend = RSStateSelectors.getResultsProcessorBackEnd(state, for: sendResultAction.backendIdentifier) {
                        backend.add(intermediateResult: sendResultAction.intermediateResult)
                    }
                    
                    return next(action)
                    
                }
            }
        }
    }

    static var defaultResultsProcessorBackEnd: RSRPBackEnd {
        return RSFakeBackEnd()
    }

}
