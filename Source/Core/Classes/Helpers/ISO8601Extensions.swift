//
//  ISO8601Extensions.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//

import Foundation

extension DateComponents {
    
    public init?(ISO8601String: String) {
        self.init()
        
        guard ISO8601String.hasPrefix("P") else {
            return nil
        }
        
        let regex = try! NSRegularExpression(pattern: "(\\d+)(Y|M|W|D|H|S)|(T)", options: [])
        let matches = regex.matches(in: ISO8601String, options: [], range: NSMakeRange(0, ISO8601String.utf16.count))
        guard matches.count > 0 else {
            return nil
        }
        
        var isTime = false
        let nsstr = ISO8601String as NSString
        for m in matches {
            if nsstr.substring(with: m.range) == "T" {
                isTime = true
                continue
            }
            
            guard let value = Int(nsstr.substring(with: m.range(at: 1))) else {
                return nil
            }
            let timeUnit = nsstr.substring(with: m.range(at: 2))
            
            switch timeUnit {
            case "Y":
                self.year = value
            case "M":
                if !isTime {
                    self.month = value
                } else {
                    self.minute = value
                }
            case "W":
                self.weekOfYear = value
            case "D":
                self.day = value
            case "H":
                self.hour = value
            case "S":
                self.second = value
            default:
                return nil
            }
        }
    }
}

extension TimeInterval {
    public init?(dateComponents: DateComponents) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        guard let futureDate = calendar.date(byAdding: dateComponents, to: now) else {
            return nil
        }
        
        self = futureDate.timeIntervalSince(now)
    }
    
    public init?(ISO8601String: String) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        guard let dateComponents = DateComponents(ISO8601String: ISO8601String),
            let futureDate = calendar.date(byAdding: dateComponents, to: now) else {
                return nil
        }
        
        self = futureDate.timeIntervalSince(now)
    }
}
