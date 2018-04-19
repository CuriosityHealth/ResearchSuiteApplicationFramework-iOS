//
//  RSPath.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
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
