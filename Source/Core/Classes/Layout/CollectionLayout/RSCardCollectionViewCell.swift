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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        //        configure border
        //        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        //        self.layer.borderWidth = 1.0
        //        self.layer.cornerRadius = 4.0
        //        self.layer.shadowRadius = 2.0
        
        let containerView = UIView()
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 8.0
        containerView.layer.shadowRadius = 8.0
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
        containerView.backgroundColor = UIColor.white
        
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
            self.titleLabel.text = title
        }
        
        if let subtitle = paramMap["subtitle"] as? String {
            self.subtitleLabel.text = subtitle
        }
        
    }
    
    override open func setCellTint(color: UIColor) {
        self.iconImageView.tintColor = color
    }
    
}
