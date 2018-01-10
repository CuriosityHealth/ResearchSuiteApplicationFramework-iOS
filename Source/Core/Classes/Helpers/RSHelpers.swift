//
//  RSHelpers.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder

public class RSHelpers {
    
    public static func getJson(forFilename filename: String, inBundle bundle: Bundle = Bundle.main, inDirectory: String? = nil) -> JsonElement? {
        
        guard let filePath = bundle.path(forResource: filename, ofType: "json", inDirectory: inDirectory) else {
                assertionFailure("unable to locate file \(filename)")
                return nil
        }
        
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            else {
                assertionFailure("Unable to create NSData with content of file \(filePath)")
                return nil
        }
        
        let json = try! JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return json as JsonElement?
    }
    
    public static func delay(_ delay:TimeInterval, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}
