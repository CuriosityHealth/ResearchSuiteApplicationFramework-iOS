//
//  RSMatch.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

import UIKit

public struct RSMatch: Equatable {
    public static func == (lhs: RSMatch, rhs: RSMatch) -> Bool {
        return lhs.path == rhs.path
    }
    
    let params: [String: AnyObject]
    let isExact: Bool
    //this should be the path UP TO THIS POINT!
    //e.g., if we match against /settings, but the entire path is /home/settings/extra
    // path here should be /home/settings
    let path: String
}


