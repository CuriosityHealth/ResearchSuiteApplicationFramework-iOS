//
//  RSCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import SnapKit
import Gloss

open class RSCollectionViewCell: UICollectionViewCell, CAAnimationDelegate {
    
    open var widthConstraint: NSLayoutConstraint!
    open var heightConstraint: NSLayoutConstraint!
    
    open var onTap: ((RSCollectionViewCell)->())?
    
    public static func spacingView(axis: UILayoutConstraintAxis) -> UIView {
        let view = UIView()
        view.snp.makeConstraints { (make) in
            if axis == .vertical {
                make.height.equalTo(0)
            }
            else {
                make.width.equalTo(0)
            }
        }
        
        return view
    }
    
    public static func lineView(axis: UILayoutConstraintAxis, color: UIColor) -> UIView {
        let view = UIView()
        view.snp.makeConstraints { (make) in
            if axis == .vertical {
                make.height.equalTo(1)
            }
            else {
                make.width.equalTo(1)
            }
        }
        
        view.backgroundColor = color
        
        return view
    }
    
    open func setCellWidth(width: CGFloat) {
        self.widthConstraint.constant = width
        self.widthConstraint.isActive = true
        
        self.heightConstraint.isActive = false
    }
    
    open func setCellHeight(height: CGFloat) {
        self.heightConstraint.constant = height
        self.heightConstraint.isActive = true
        
        self.widthConstraint.isActive = false
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        self.widthConstraint = self.contentView.widthAnchor.constraint(equalToConstant: 0.0)
        self.heightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 0.0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open override func prepareForReuse() {
        self.onTap = nil
        super.prepareForReuse()
    }
    
    open override var isHighlighted: Bool {
        
        get {
            return super.isHighlighted
        }
        
        set(newIsHighlighted) {
            
            if self.onTap != nil {
                super.isHighlighted = newIsHighlighted
                self.updateShadow(shadow: !newIsHighlighted, animated: false)
            }
            
        }

    }
    
    @objc
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let shadowOpacity: Float = self.isHighlighted ? 0.0 : 0.3
        self.layer.shadowOpacity = shadowOpacity
    }
    
    func updateShadow(shadow: Bool, animated: Bool) {

        let opacity: Float = shadow ? 0.3 : 0.0
        
//        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowColor = (self.onTap == nil) ? UIColor.black.cgColor : self.tintColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 3.0
        
        if animated {
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.duration = 0.025
            animation.fromValue = self.layer.shadowOpacity
            animation.toValue = opacity
            animation.delegate = self
            self.layer.add(animation, forKey: "shadowOpacity")
        }
        else {
            self.layer.shadowOpacity = opacity
        }

    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.updateShadow(shadow: !self.isHighlighted, animated: false)
    }
    
    open func configure(paramMap: [String : Any]){

    }
    
    @objc
    open func cellTapped(sender: UITapGestureRecognizer) {
        self.onTap?(self)
    }
    
    open func setCellTint(color: UIColor) {
        self.tintColor = color
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
