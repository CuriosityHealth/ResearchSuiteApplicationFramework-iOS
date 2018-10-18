//
//  RSCardCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit

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
    //then content container
    open var contentStackView: UIStackView!
    
    open var containerView: UIView!
    
    open override var onTap: ((RSCollectionViewCell)->())? {
        didSet {
            self.updateBorder(tintedBorder: self.onTap != nil, isHighlighted: self.isHighlighted)
        }
    }
    
    open override var isHighlighted: Bool {
        
        didSet {
            self.updateBackgroundColor(isHighlighted: isHighlighted)
            self.updateBorder(tintedBorder: self.onTap != nil, isHighlighted: isHighlighted)
        }
        
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        //        configure border
        //        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        //        self.layer.borderWidth = 1.0
        //        self.layer.cornerRadius = 4.0
        //        self.layer.shadowRadius = 2.0
        
        let containerView = UIView()
        self.containerView = containerView
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
//        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
//        containerView.layer.borderWidth = 1.0
//        containerView.layer.cornerRadius = 8.0
//        containerView.layer.shadowRadius = 8.0
//        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
//        containerView.backgroundColor = UIColor.white
        self.updateBackgroundColor(isHighlighted: false)
        
        let verticalStackView = UIStackView(frame: self.contentView.bounds)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8.0
        
        containerView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
            
        }
        
        self.titleLabel = RSCardCellTitleLabel()
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel = RSCardCellSubtitleLabel()
        self.subtitleLabel.numberOfLines = 0
        self.iconImageView = UIImageView()
        self.iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
        
        self.contentStackView = UIStackView()
        
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
        
        let subtitleStackView = UIStackView()
        verticalStackView.addArrangedSubview(subtitleStackView)
        
        subtitleStackView.axis = .horizontal
        subtitleStackView.spacing = 8.0
        
        subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        subtitleStackView.addArrangedSubview(self.subtitleLabel)
        subtitleStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
        verticalStackView.addArrangedSubview(self.contentStackView)
        
        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.updateBorder(tintedBorder: self.onTap != nil, isHighlighted: self.isHighlighted)
    }
    
    override open func prepareForReuse() {
        
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.iconImageView.image = nil
        self.iconImageView.tintColor = nil
        
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
        
        if let subtitle = paramMap["subtitle"] as? String {
            self.subtitleLabel.text = RSApplicationDelegate.localizedString(subtitle)
        }
        
    }
    
    func updateBorder(tintedBorder: Bool, isHighlighted: Bool) {
        
        self.containerView.layer.borderColor = {
            if tintedBorder {
                return self.tintColor.withAlphaComponent(0.3).cgColor
            }
            else {
                return UIColor.lightGray.withAlphaComponent(0.3).cgColor
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
        self.containerView.backgroundColor = isHighlighted ? UIColor.lightGray.withAlphaComponent(0.2) : UIColor.white
    }
    
    override open func setCellTint(color: UIColor) {
        super.setCellTint(color: color)
        self.iconImageView.tintColor = color
        self.updateBorder(tintedBorder: self.onTap != nil, isHighlighted: self.isHighlighted)
    }
    
}
