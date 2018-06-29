//
//  RSBasicCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit

open class RSBasicCollectionViewCell: RSCollectionViewCell, RSCollectionViewCellGenerator {
    
    public static var identifier: String = "basicCollectionViewCell"
    
    public static var collectionViewCellClass: AnyClass = RSBasicCollectionViewCell.self
    
    open var stackView: UIStackView!
    open var textLabel: UILabel!
    open var detailTextLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(frame: self.contentView.bounds)
        stackView.axis = .vertical
        stackView.spacing = 8.0
        
        self.stackView = stackView
        
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
        }
        
        self.textLabel = UILabel()
        self.textLabel.numberOfLines = 0
        self.detailTextLabel = UILabel()
        self.detailTextLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(RSBasicCollectionViewCell.spacingView(axis: .vertical))
        stackView.addArrangedSubview(self.textLabel)
        stackView.addArrangedSubview(self.detailTextLabel)
        stackView.addArrangedSubview(RSBasicCollectionViewCell.lineView(axis: .vertical, color: UIColor.lightGray.withAlphaComponent(0.3)))
        
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        
        self.textLabel.text = nil
        self.detailTextLabel.text = nil
        
        super.prepareForReuse()
        
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let title = paramMap["title"] as? String {
            self.textLabel.text = RSApplicationDelegate.localizedString(title)
        }
        
        if let subtitle = paramMap["subtitle"] as? String {
            self.detailTextLabel.text = RSApplicationDelegate.localizedString(subtitle) 
        }
        
    }
    
}
