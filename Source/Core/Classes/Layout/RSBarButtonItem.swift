//
//  RSBarButtonItem.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import ResearchSuiteTaskBuilder

open class RSBarButtonItem: UIBarButtonItem {
    
    public let layoutButton: RSLayoutButton
    public let onTap: ((RSBarButtonItem) -> ())?
    
    public init?(layoutButton: RSLayoutButton, onTap: ((RSBarButtonItem) -> ())?, localizationHelper: RSTBLocalizationHelper) {
        
        self.layoutButton = layoutButton
        self.onTap = onTap
        super.init()
        self.style = .plain
        self.target = self
        self.action = #selector(tappedButton)
        if let image = layoutButton.image {
            self.image = image
        }
        else if let title = layoutButton.title {
            self.title = localizationHelper.localizedString(title)
        }
        else {
            return nil
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func tappedButton() {
        self.onTap?(self)
    }

}
