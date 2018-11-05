//
//  RSPath.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

public protocol RSPath: CustomStringConvertible {
    func match(remainingPath: String, previousPath: String, fullURL: URL) -> RSMatch?
    func remainder(path: String) -> String
//    func parameters(path: String) -> [String: AnyObject]?
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
    
    public func match(remainingPath: String, previousPath: String, fullURL: URL) -> RSMatch? {
        
        if self.path == remainingPath {
            let isFinal = self.remainder(path: remainingPath).count == 0
            return RSMatch(
                isExact: true,
                path: previousPath + self.path,
                params: [:],
                fullURL: fullURL,
                isFinal: isFinal
            )
        }
        else {
            return nil
        }
    }
    
    public func remainder(path: String) -> String {
        assert(path == self.path, "Paths must match for exact paths")
        return ""
    }
    
//    public func parameters(path: String) -> [String: AnyObject]? {
//        return nil
//    }
    
    let path: String
    public init(path: String) {
        self.path = path.lowercased()
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
    
    public func match(remainingPath: String, previousPath: String, fullURL: URL) -> RSMatch? {
        
        if remainingPath.lowercased().hasPrefix(self.prefix) {
            let isFinal = self.remainder(path: remainingPath).count == 0
            return RSMatch(
                isExact: false,
                path: previousPath + self.prefix,
                params: [:],
                fullURL: fullURL,
                isFinal: isFinal
            )
        }
        
        return nil
    }
    
    public func remainder(path: String) -> String {
        return String(path.dropFirst(self.prefix.count))
    }
    
//    public func parameters(path: String) -> [String: AnyObject]? {
//        return nil
//    }
    
    let prefix: String
    public init(prefix: String) {
        self.prefix = prefix.lowercased()
    }
    
    public var description: String {
        return "RSPrefixPath: \(self.prefix)"
    }
}

open class RSParamPath: RSPath, RSPathGenerator {
    
    enum ParamType: String {
        
        case int = "int"
        case str = "str"
        case uuid = "uuid"
        
        var paramRegexString: String {
            switch self {
            case .str:
                return "(\\\\w+?)"
            case .int:
                return "(\\\\d+?)"
            case .uuid:
                return "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})"
            }
        }
        
        func convert(str: String) -> Any? {
            
            switch self {
            case .int:
                return Int(str)
            case .str:
                return str
            case .uuid:
//                print(str)
                return UUID(uuidString: str)
            }
            
        }
    }
    
    struct Param {
        let name: String
        let paramType: ParamType
    }

    open static func supportsType(type: String) -> Bool {
        return type == "param"
    }

    open static func generate(jsonObject: JSON, state: RSState) -> RSPath? {
        guard let path: String = "path" <~~ jsonObject else {
            return nil
        }

        return RSParamPath(path: path)
    }

    public func match(remainingPath: String, previousPath: String, fullURL: URL) -> RSMatch? {

        //convert /samples/<id> into regex
        
        let matches = self.regex.matches(in: remainingPath, options: [], range: NSMakeRange(0, remainingPath.count))
        if let match = matches.first {
            
            let fullMatchedPath: String = {
                let completeMatch = match.range(at: 0)
//                print(completeMatch)
                let start = remainingPath.index(remainingPath.startIndex, offsetBy: completeMatch.lowerBound)
                let end = remainingPath.index(remainingPath.startIndex, offsetBy: completeMatch.upperBound)
                let matchedPath = String(remainingPath[start..<end])
                if matchedPath.last == "/" {
                    return String(matchedPath.dropLast())
                }
                else {
                    return matchedPath
                }
            }()
        
            
            var paramDict: [String: Any] = [:]
            
            self.params.enumerated().forEach { (pair) in
                
                let paramRange = match.range(at: pair.offset + 1)
                let start = remainingPath.index(remainingPath.startIndex, offsetBy: paramRange.lowerBound)
                let end = remainingPath.index(remainingPath.startIndex, offsetBy: paramRange.upperBound)
//                print(start, end)
                let substring = remainingPath[start..<end]
                paramDict[pair.element.name] =  pair.element.paramType.convert(str: String(substring))
            }
            
            let remainder = "/\(remainingPath.dropFirst(match.range.length))"
//            print(remainder)
            let isFinal = remainder.count == 0
            
            return RSMatch(
                isExact: false,
                path: previousPath + fullMatchedPath,
                params: paramDict,
                fullURL: fullURL,
                isFinal: isFinal
            )
        }
        else {
            return nil
        }

    }

    public func remainder(path: String) -> String {
        
        let matches = self.regex.matches(in: path, options: [], range: NSMakeRange(0, path.count))
        let match = matches.first!
        
        let remainder = path.dropFirst(match.range.length)
        
        if remainder.count > 0 {
            return "/\(remainder))"
        }
        else {
            return ""
        }
    }

    public func parameters(path: String) -> [String: AnyObject]? {
        return nil
    }

    let path: String
    let params: [Param]
    let regex: NSRegularExpression
    
    class func generateParams(path: String) throws -> [Param] {
        let paramPattern = "<.+?>"
        let paramRegex = try NSRegularExpression(pattern: paramPattern, options: [])
        let matches = paramRegex.matches(in: path, options: [], range: NSMakeRange(0, path.count))
        
        let params = matches.compactMap { result -> Param? in
            let start = path.index(path.startIndex, offsetBy: result.range.lowerBound+1)
            let end = path.index(path.startIndex, offsetBy: result.range.upperBound-1)
            let subrange = start..<end
            let substring = path[subrange]
            
            let pair = String(substring).split(separator: ":")
            
            guard let paramType = ParamType(rawValue: String(pair[0])) else {
                return nil
            }
            
            let param = Param(name: String(pair[1]), paramType: paramType)
            
            return param
        }
        
        return params
    }
    
    class func generateRegEx(path: String, params: [Param]) throws -> NSRegularExpression {
        let paramPattern = "<.+?>"
        let paramRegex = try! NSRegularExpression(pattern: paramPattern, options: [])
        let matches = paramRegex.matches(in: path, options: [], range: NSMakeRange(0, path.count))
        
        let pattern = zip(matches, params).reduce(path) { (accString, arg1) -> String in
            
            let (result, param) = arg1
            let start = path.index(path.startIndex, offsetBy: result.range.lowerBound)
            let end = path.index(path.startIndex, offsetBy: result.range.upperBound)
            let subrange = start..<end
            let substring = String(path[subrange])
            
            return accString.replacingOccurrences(of: substring, with: param.paramType.paramRegexString, options: .regularExpression, range: nil)
            
            }
        
        let finalPattern = "^" + pattern + "(/|$)"
        
        let regex = try NSRegularExpression(pattern: finalPattern, options: [.caseInsensitive])
        return regex
    }
    
    
    
    public init?(path: String) {
        self.path = path
        do {
            let params = try RSParamPath.generateParams(path: path)
            let regex = try RSParamPath.generateRegEx(path: path, params: params)
            
            self.params = params
            self.regex = regex
        }
        catch let error {
//            debugPrint(error)
            return nil
        }
        
    }

    public var description: String {
        return "RSParamPath: \(self.regex)"
    }
}

open class RSBrowserPath: RSPath, RSPathGenerator {
    
    open static func supportsType(type: String) -> Bool {
        return type == "browser"
    }
    
    open static func generate(jsonObject: JSON, state: RSState) -> RSPath? {
        guard let prefix: String = "path" <~~ jsonObject else {
            return nil
        }
        
        return RSBrowserPath(prefix: prefix)
    }
    
    public func match(remainingPath: String, previousPath: String, fullURL: URL) -> RSMatch? {
        
        if remainingPath.hasPrefix(self.prefix) {
            let isFinal = self.remainder(path: remainingPath).count == 0
            return RSMatch(
                isExact: false,
                path: previousPath + remainingPath,
                params: [:],
                fullURL: fullURL,
                isFinal: isFinal
            )
        }
        
        return nil
    }
    
    public func remainder(path: String) -> String {
        return ""
    }
    
    //    public func parameters(path: String) -> [String: AnyObject]? {
    //        return nil
    //    }
    
    let prefix: String
    public init(prefix: String) {
        self.prefix = prefix.lowercased()
    }
    
    public var description: String {
        return "RSBrowserPath: \(self.prefix)"
    }
}

