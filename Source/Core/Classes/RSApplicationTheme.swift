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
    public let navigationBarTitleColor: UIColor?
    public let navigationBarIconColor: UIColor?
    
    public let tabBarBackgroundColor: UIColor?
    public let tabBarActiveIconColor: UIColor?
    public let tabBarInactiveIconColor: UIColor?
    
    public let windowTintColor: UIColor?
    
    public init(
        windowTintColor: UIColor? = nil,
        navigationBarBackgroundColor: UIColor? = nil,
        navigationBarTitleColor: UIColor? = nil,
        navigationBarIconColor: UIColor? = nil,
        tabBarBackgroundColor: UIColor? = nil,
        tabBarActiveIconColor: UIColor? = nil,
        tabBarInactiveIconColor: UIColor? = nil
        ) {
        
        self.windowTintColor = windowTintColor
        self.navigationBarBackgroundColor = navigationBarBackgroundColor
        self.navigationBarTitleColor = navigationBarTitleColor
        self.navigationBarIconColor = navigationBarIconColor
        self.tabBarBackgroundColor = tabBarBackgroundColor
        self.tabBarActiveIconColor = tabBarActiveIconColor
        self.tabBarInactiveIconColor = tabBarInactiveIconColor
        
    }
    public init?(json: JSON) {
        return nil
    }
    
}
