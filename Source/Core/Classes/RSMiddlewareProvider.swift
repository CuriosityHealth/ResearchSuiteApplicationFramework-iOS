//
//  RSMiddlewareProvider.swift
//  Pods
//
//  Created by James Kizer on 7/20/17.
//
//

import ReSwift

public protocol RSMiddlewareProvider {
    static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware
}
