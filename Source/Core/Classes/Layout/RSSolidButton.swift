//
//  RSSolidButton.swift
//  Pods
//
//  Created by James Kizer on 9/13/18.
//

import UIKit
import ResearchSuiteExtensions

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
extension UIButton {
    func setBackgroundColor(backgroundColor: UIColor?, for state: UIControl.State) {
        if let color = backgroundColor {
            self.setBackgroundImage(UIImage.from(color: color), for: state)
        }
        else {
            self.setBackgroundImage(nil, for: state)
        }
    }
    
}

open class RSSolidButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.initButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.initButton()
    }
    
    private func initButton() {
        self.titleLabel?.font = self.defaultFont
    }
    
    public var userInfo: [String: Any]? = nil
    var solidBackgroundColor: UIColor?
    public func setColors(titleColor: UIColor, backgroundColor: UIColor?) {
        
        self.solidBackgroundColor = backgroundColor
        
        let backgroundColor = backgroundColor ?? UIColor.clear
        
        //normal
        self.setTitleColor(titleColor, for: UIControl.State.normal)
        self.setBackgroundColor(backgroundColor: backgroundColor, for: UIControl.State.normal)
        
        //disabled
        self.setTitleColor(titleColor.withAlphaComponent(0.7), for: UIControl.State.disabled)
        self.setBackgroundColor(backgroundColor: backgroundColor.withAlphaComponent(0.3), for: UIControl.State.disabled)
        
        //highlighted
        self.setTitleColor(backgroundColor, for: UIControl.State.highlighted)
        self.setBackgroundColor(backgroundColor: titleColor, for: UIControl.State.highlighted)
        
        //selected
        self.setTitleColor(backgroundColor, for: UIControl.State.selected)
        self.setBackgroundColor(backgroundColor: titleColor, for: UIControl.State.selected)
        
    }
    
//    private func setTitleColor(_ color: UIColor?) {
//        self.setTitleColor(color, for: UIControl.State.normal)
//        self.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
//        self.setTitleColor(UIColor.white, for: UIControl.State.selected)
//        self.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: UIControl.State.disabled)
//
//        self.setBackgroundColor(backgroundColor: color, for: UIControl.State.highlighted)
//        self.setBackgroundColor(backgroundColor: color, for: UIControl.State.selected)
//    }
    
    var configuredColor: UIColor? {
        didSet {
            if let color = self.configuredColor {
                self.setColors(titleColor: color, backgroundColor: self.solidBackgroundColor)
            }
            else {
                self.setColors(titleColor: self.tintColor, backgroundColor: self.solidBackgroundColor)
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let color = self.solidBackgroundColor {
            if self.state == .disabled {
                self.layer.borderColor = UIColor.clear.cgColor
            }
            else {
                self.layer.borderColor = color.cgColor
            }
            
        }
    }
    
    override open func tintColorDidChange() {
        //if we have not configured the color, set
        super.tintColorDidChange()
        if let _ = self.configuredColor {
            return
        }
        else {
            self.setColors(titleColor: self.tintColor, backgroundColor: self.solidBackgroundColor)
        }
    }
    
    override open var intrinsicContentSize : CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width + 20.0, height: superSize.height)
    }
    
    open var defaultFont: UIFont {
        // regular, 14
        return RSBorderedButton.defaultFont
    }
    
    open class var defaultFont: UIFont {
        // regular, 14
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.headline)
        let fontSize: Double = (descriptor.object(forKey: UIFontDescriptor.AttributeName.size) as! NSNumber).doubleValue
        return UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
}
