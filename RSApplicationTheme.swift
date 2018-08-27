//
//  RSApplicationTheme.swift
//  Pods
//
//  Created by James Kizer on 8/27/18.
//

import UIKit
import Gloss

public struct RSApplicationTheme: JSONDecodable {
    
    public let navigationBarBackgroundColor: UIColor?
    public let navigationTitleColor: UIColor?
    public let tabBarBackgroundColor: UIColor?
    
    public init(
        navigationBarBackgroundColor: UIColor? = nil,
        navigationTitleColor: UIColor? = nil,
        tabBarBackgroundColor: UIColor? = nil
        ) {
        
        self.navigationBarBackgroundColor = navigationBarBackgroundColor
        self.navigationTitleColor = navigationTitleColor
        self.tabBarBackgroundColor = tabBarBackgroundColor
        
    }
    public init?(json: JSON) {
        return nil
    }
    
}
