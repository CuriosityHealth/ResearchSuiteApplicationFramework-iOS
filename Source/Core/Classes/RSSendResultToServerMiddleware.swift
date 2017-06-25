//
//  RSSendResultToServerMiddleware.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor

open class RSSendResultToServerMiddleware {
    
    //public typealias Middleware = (DispatchFunction?, @escaping GetState) -> (@escaping DispatchFunction) -> DispatchFunction
    static func sendResultToServerMidleware() -> Middleware {
        return { dispatch, getState in
            return { next in
                return { action in
                    
                    if let sendResultAction = action as? RSSendResultToServerAction {
                        RSSendResultToServerMiddleware.defaultResultsProcessorBackEnd.add(intermediateResult: sendResultAction.intermediateResult)
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
