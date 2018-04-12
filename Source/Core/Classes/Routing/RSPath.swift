//
//  RSPath.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

import UIKit
import Gloss
import ReSwift

public protocol RSPath: CustomStringConvertible {
    func match(remainingPath: String, previousPath: String) -> RSMatch?
    func remainder(path: String) -> String
    func parameters(path: String) -> [String: AnyObject]?
}

open class RSExactPath: RSPath, RSPathGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "exact"
    }
    
    public static func generate(jsonObject: JSON, state: RSState) -> RSPath? {
        guard let path: String = "path" <~~ jsonObject else {
            return nil
        }
        
        return RSExactPath(path: path)
    }
    
    public func match(remainingPath: String, previousPath: String) -> RSMatch? {
        
        if self.path == remainingPath {
            return RSMatch(params: [:], isExact: true, path: previousPath + self.path)
        }
        else {
            return nil
        }
    }
    
    public func remainder(path: String) -> String {
        assert(path == self.path, "Paths must match for exact paths")
        return ""
    }
    
    public func parameters(path: String) -> [String: AnyObject]? {
        return nil
    }
    
    let path: String
    public init(path: String) {
        self.path = path
    }
    
    public var description: String {
        return "RSExactPath: \(self.path)"
    }
}

open class RSPrefixPath: RSPath, RSPathGenerator {
    
    open static func supportsType(type: String) -> Bool {
        return type == "prefix"
    }
    
    open static func generate(jsonObject: JSON, state: RSState) -> RSPath? {
        guard let prefix: String = "path" <~~ jsonObject else {
            return nil
        }
        
        return RSPrefixPath(prefix: prefix)
    }
    
    public func match(remainingPath: String, previousPath: String) -> RSMatch? {
        
        if remainingPath.hasPrefix(self.prefix) {
            return RSMatch(params: [:], isExact: false, path: previousPath + self.prefix)
        }
        
        return nil
    }
    
    public func remainder(path: String) -> String {
        return String(path.dropFirst(self.prefix.count))
    }
    
    public func parameters(path: String) -> [String: AnyObject]? {
        return nil
    }
    
    let prefix: String
    public init(prefix: String) {
        self.prefix = prefix
    }
    
    public var description: String {
        return "RSPrefixPath: \(self.prefix)"
    }
}
