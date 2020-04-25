//
//  RSCardCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import Gloss

open class RSCardCollectionViewCellConfiguration: RSCollectionViewCellConfiguration {
    
    let icon: String?
    let title: String?
    let subtitle: String?
    
    public init(
        icon: String?,
        title: String?,
        subtitle: String?
        ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
//    public required init?(json: JSON) {
//        self.icon = "icon" <~~ json
//        self.title = "title" <~~ json
//        self.subtitle = "subtitle" <~~ json
//
//        super.init(json: json)
//    }
//
//    public override func toJSON() -> JSON? {
//
//        let parent: JSON = super.toJSON() ?? [:]
//        let this: JSON = jsonify([
//            "icon" ~~> self.icon,
//            "title" ~~> self.title,
//            "subtitle" ~~> self.subtitle,
//            ]) ?? [:]
//
//        return parent.merging(this, uniquingKeysWith: {$1})
//    }
    
}

open class RSCardCollectionViewCell: RSCollectionViewCell {
    
    //icon
    //title
    //subtitle
    //contentStackView
    //icon and title on at the top in a horizontal container
    open var iconImageView: UIImageView!
    open var titleLabel: UILabel!
    //subtitle next
    open var subtitleLabel: UILabel!
    open var subtitleStackView: UIStackView!
    //then content container
    open var contentStackView: UIStackView!
    
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
//        verticalStackView.setContentHuggingPriority(.required, for: .vertical)
//        verticalStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        self.titleLabel = RSCardCellTitleLabel()
        self.titleLabel.numberOfLines = 0
//        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.subtitleLabel = RSCardCellSubtitleLabel()
        self.subtitleLabel.numberOfLines = 0
//        self.subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
//        self.subtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(1)
        }
        
        self.iconImageView = UIImageView()
        self.iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
        
        self.contentStackView = UIStackView()
//        self.contentStackView.setContentCompressionResistancePriority(.required, for: .vertical)
//        self.contentStackView.setContentHuggingPriority(.required, for: .vertical)
        //start to add views
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        
        //configure header view
        let headerStackView = UIStackView()
        verticalStackView.addArrangedSubview(headerStackView)
        
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8.0
        
        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        headerStackView.addArrangedSubview(self.iconImageView)
        headerStackView.addArrangedSubview(self.titleLabel)
        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
        self.subtitleStackView = UIStackView()
        verticalStackView.addArrangedSubview(self.subtitleStackView)
//        subtitleStackView.setContentCompressionResistancePriority(.required, for: .vertical)
//        subtitleStackView.setContentHuggingPriority(.required, for: .vertical)
        
        self.subtitleStackView.axis = .horizontal
        self.subtitleStackView.spacing = 8.0
        
//        subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
//        subtitleStackView.addArrangedSubview(self.subtitleLabel)
//        subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
        verticalStackView.addArrangedSubview(self.contentStackView)
        
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
        self.subtitleLabel.text = nil
        self.subtitleStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        self.iconImageView.image = nil
        self.iconImageView.tintColor = nil
        self.unselectedBackgroundColor = UIColor.white
        
        super.prepareForReuse()
        
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let iconString = paramMap["icon"] as? String,
            let icon = UIImage(named: iconString) {
            if #available(iOS 13.0, *) {
                self.iconImageView.image = icon.withTintColor(UIColor.red)
            } else {
                self.iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            }
        }
        
        if let title = paramMap["title"] as? String {
            self.titleLabel.text = RSApplicationDelegate.localizedString(title)
        }
        
        if let subtitle = paramMap["subtitle"] as? String {
            self.subtitleLabel.text = RSApplicationDelegate.localizedString(subtitle)
            self.subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            self.subtitleStackView.addArrangedSubview(self.subtitleLabel)
            self.subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        }
        else {
            //add view of zero height
            subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .vertical))
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

        if let subtitle = typedConfig.subtitle {
            self.subtitleLabel.text = RSApplicationDelegate.localizedString(subtitle)
            self.subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            self.subtitleStackView.addArrangedSubview(self.subtitleLabel)
            self.subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        }
        else {
            //add view of zero height
            subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .vertical))
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
