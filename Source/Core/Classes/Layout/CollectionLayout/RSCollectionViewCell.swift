//
//  RSCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import SnapKit
import Gloss

open class RSCollectionViewCell: UICollectionViewCell {
    
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
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.widthConstraint = self.contentView.widthAnchor.constraint(equalToConstant: 0.0)
        self.heightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 0.0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    open override func prepareForReuse() {
        self.onTap = nil
        super.prepareForReuse()
    }
    
    
    open func configure(paramMap: [String : Any]){

    }
    
    @objc
    open func cellTapped() {
        self.onTap?(self)
    }
    
    open func setCellTint(color: UIColor) {
        
        
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
