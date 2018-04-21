//
//  RSMiddlewareProvider.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import ReSwift

public protocol RSMiddlewareProvider {
    static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware?
}
