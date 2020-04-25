//
//  RSBasicCardCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 8/21/19.
//

import UIKit
import Gloss

open class RSBasicCardCollectionViewCell: RSCollectionViewCell, RSCollectionViewCellGenerator {
    public static var identifier: String {
        return "basicCardCell"
    }
    
    public static var collectionViewCellClass: AnyClass {
        return RSBasicCardCollectionViewCell.self
    }
    
    
    
    
    //icon
    //title
    //subtitle
    //contentStackView
    //icon and title on at the top in a horizontal container
    open var iconImageView: UIImageView!
    open var titleLabel: UILabel!
    
    open var containerView: UIView!
    
    open var unselectedBackgroundColor: UIColor = UIColor.white {
        didSet {
            self.updateBackgroundColor(isHighlighted: self.isHighlighted)
        }
    }
    
    open override var onTap: ((RSCollectionViewCell)->())? {
        didSet {
            self.updateBorder(active: self.onTap != nil, isHighlighted: self.isHighlighted)
        }
    }
    
    open override var isHighlighted: Bool {
        
        didSet {
            self.updateBackgroundColor(isHighlighted: isHighlighted)
            self.updateBorder(active: self.onTap != nil, isHighlighted: isHighlighted)
        }
        
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.containerView = UIView()
        self.containerView.setContentHuggingPriority(.required, for: .vertical)
        self.contentView.setContentHuggingPriority(.required, for: .vertical)
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        self.updateBackgroundColor(isHighlighted: false)
        
        let verticalStackView = UIStackView()
        verticalStackView.setContentHuggingPriority(.required, for: .vertical)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8.0

        containerView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()

        }
        
        self.titleLabel = RSCardCellTitleLabel()
        self.titleLabel.numberOfLines = 0

        self.iconImageView = UIImageView()
        self.iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }

        //start to add views
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        
        //configure header view
        let headerStackView = UIStackView()
        verticalStackView.addArrangedSubview(headerStackView)
        
//        containerView.addSubview(headerStackView)
//        headerStackView.snp.makeConstraints { (make) in
//            make.width.height.equalToSuperview()
//            make.center.equalToSuperview()
//        }
        
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8.0
        
        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        headerStackView.addArrangedSubview(self.iconImageView)
        headerStackView.addArrangedSubview(self.titleLabel)
        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.updateBorder(active: self.onTap != nil, isHighlighted: self.isHighlighted)
    }
    
    override open func prepareForReuse() {
        
        self.titleLabel.text = nil
        self.iconImageView.image = nil
        self.iconImageView.tintColor = nil
        self.unselectedBackgroundColor = UIColor.white
        
        super.prepareForReuse()
        
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let iconString = paramMap["icon"] as? String,
            let icon = UIImage(named: iconString) {
            self.iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
        }
        
        if let title = paramMap["title"] as? String {
            self.titleLabel.text = RSApplicationDelegate.localizedString(title)
        }
        
    }
    
    open override func configure(config: RSCollectionViewCellConfiguration) {
        
        super.configure(config: config)
        
        guard let typedConfig = config as? RSCardCollectionViewCellConfiguration else {
            return
        }
        
        if let iconString = typedConfig.icon,
            let icon = UIImage(named: iconString) {
            self.iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
        }

        if let title = typedConfig.title {
            self.titleLabel.text = RSApplicationDelegate.localizedString(title)
        }
        
    }
    
    func updateBorder(active: Bool, isHighlighted: Bool) {
        
        self.containerView.layer.borderColor = {
            if active {
                if let color = self.activeBorderColor {
                    return color.cgColor
                }
                else {
                    return self.tintColor.withAlphaComponent(0.3).cgColor
                }
            }
            else {
                if let color = self.inactiveBorderColor {
                    return color.cgColor
                }
                else {
                    return UIColor.lightGray.withAlphaComponent(0.3).cgColor
                }
            }
        }()
        
        if isHighlighted {
            self.containerView.layer.borderWidth = 0.0
        }
        else {
            self.containerView.layer.borderWidth = 1.0
        }
        
        self.containerView.layer.cornerRadius = 8.0
        
    }
    
    func updateBackgroundColor(isHighlighted: Bool) {
        self.containerView.backgroundColor = isHighlighted ? UIColor.lightGray.withAlphaComponent(0.2) : self.unselectedBackgroundColor
    }
    
    override open func setCellTint(color: UIColor) {
        super.setCellTint(color: color)
        self.iconImageView.tintColor = color
        self.updateBorder(active: self.onTap != nil, isHighlighted: self.isHighlighted)
    }
    
}
