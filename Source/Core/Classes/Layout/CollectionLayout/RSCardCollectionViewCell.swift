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
            make.width.equalToSuperview().offset(-40)
            make.height.equalToSuperview().offset(-20)
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
        
//        let contentStackView = UIStackView()
//        verticalStackView.addArrangedSubview(contentStackView)
//
//        contentStackView.axis = .horizontal
//        contentStackView.spacing = 8.0
//
//        contentStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
//        contentStackView.addArrangedSubview(self.contentStackView)
//        contentStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
        
        //        self.textLabel = UILabel()
        //        self.textLabel.numberOfLines = 0
        //        self.detailTextLabel = UILabel()
        //        self.detailTextLabel.numberOfLines = 0
        
        
        
        //        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        //
        //        let headerStackView = UIStackView()
        //        verticalStackView.addArrangedSubview(headerStackView)
        //
        //        headerStackView.axis = .horizontal
        //        headerStackView.spacing = 8.0
        //
        //        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        //
        //        self.headerLabel = RSLabel()
        //        self.headerLabel.numberOfLines = 0
        //        headerStackView.addArrangedSubview(self.headerLabel)
        //
        //        headerStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        //
        //        self.combinedMapImageView = UIView()
        //        self.combinedMapImageView.snp.makeConstraints { (make) in
        //            make.height.equalTo(self.combinedMapImageView.snp.width)
        //        }
        //
        //        verticalStackView.addArrangedSubview(self.combinedMapImageView)
        //
        //
        //
        //        let mapView = MKMapView(frame: CGRect.zero)
        //        self.combinedMapImageView.addSubview(mapView)
        //        mapView.snp.makeConstraints { (make) in
        //            make.height.width.equalToSuperview()
        //            make.center.equalToSuperview()
        //        }
        //
        //        mapView.delegate = self
        //        mapView.isUserInteractionEnabled = false
        //        //        verticalStackView.addArrangedSubview(mapView)
        //
        //        self.mapView = mapView
        //
        //        let imageView = UIImageView()
        //        self.combinedMapImageView.addSubview(imageView)
        //        imageView.snp.makeConstraints { (make) in
        //            make.height.width.equalToSuperview()
        //            make.center.equalToSuperview()
        //        }
        //
        //        self.mapImageView = imageView
        //
        //        let detailStackView = UIStackView()
        //        verticalStackView.addArrangedSubview(detailStackView)
        //
        //        detailStackView.axis = .vertical
        //        detailStackView.spacing = 8.0
        //
        //        self.titleLabel = RSTitleLabel()
        //        self.titleLabel.numberOfLines = 0
        //        detailStackView.addArrangedSubview(self.titleLabel)
        //
        //        self.subtitleLabel = RSTextLabel()
        //        self.subtitleLabel.numberOfLines = 0
        //        detailStackView.addArrangedSubview(self.subtitleLabel)
        //
        //        verticalStackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.iconImageView.image = nil
        
        super.prepareForReuse()
        
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let iconString = paramMap["icon"] as? String,
            let icon = UIImage(named: iconString) {
            self.iconImageView.image = icon
        }
        
        if let title = paramMap["title"] as? String {
            self.titleLabel.text = title
        }
        
        if let subtitle = paramMap["subtitle"] as? String {
            self.subtitleLabel.text = subtitle
        }
        
    }
    
}
