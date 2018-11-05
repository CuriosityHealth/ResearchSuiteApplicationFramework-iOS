//
//  RSMatch.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public struct RSMatch: Equatable, JSONEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify([
            "params" ~~> self.params,
            "isExact" ~~> self.isExact,
            "path" ~~> self.path
            ])
    }
    
    public static func == (lhs: RSMatch, rhs: RSMatch) -> Bool {
        return lhs.path == rhs.path
    }
    
    
    public let isExact: Bool
    //this should be the path UP TO THIS POINT!
    //e.g., if we match against /settings, but the entire path is /home/settings/extra
    // path here should be /home/settings
    public let path: String
    public let params: [String: Any]
    
    public let fullURL: URL
    public let isFinal: Bool
    
    public var queryString: String? {
        if self.isFinal {
            return self.fullURL.query
        }
        else {
            return nil
        }
    }
    
    public var queryParams: [String: String] {
        if self.isFinal {
            return self.fullURL.queryDictionary ?? [:]
        }
        else {
            return [:]
        }
    }
    
    public var pathAndQuery: String {
        if let queryString = self.queryString {
            return "\(self.path)?\(queryString)"
        }
        else {
            return self.path
        }
    }
}


