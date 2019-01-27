//
//  RSTextCardCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import Gloss

open class RSTextCardCollectionViewCellConfiguration: RSCardCollectionViewCellConfiguration {
    
    let body: String?
    
    public init(
        icon: String?,
        title: String?,
        subtitle: String?,
        body: String?
        ) {
        self.body = body
        super.init(icon: icon, title: title, subtitle: subtitle)
    }
    
//    public required init?(json: JSON) {
//        self.body = "body" <~~ json
//        super.init(json: json)
//    }
//
//    public override func toJSON() -> JSON? {
//
//        let parent: JSON = super.toJSON() ?? [:]
//        let this: JSON = jsonify([
//            "body" ~~> self.body
//            ]) ?? [:]
//
//        return parent.merging(this, uniquingKeysWith: {$1})
//    }
    
}

open class RSTextCardCollectionViewCell: RSCardCollectionViewCell, RSCollectionViewCellGenerator {

    open class var identifier: String {
        return "textCardCell"
    }
    
    open class var collectionViewCellClass: AnyClass {
        return RSTextCardCollectionViewCell.self
    }
    
    
    open var bodyTextLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.bodyTextLabel = UILabel()
        self.bodyTextLabel.numberOfLines = 0
        
        let bodyStackView = UIStackView()
        self.contentStackView.addArrangedSubview(bodyStackView)
        
        bodyStackView.axis = .horizontal
        bodyStackView.spacing = 8.0
        
        bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        bodyStackView.addArrangedSubview(self.bodyTextLabel)
        bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        
        self.bodyTextLabel.text = nil
        
        super.prepareForReuse()
        
    }

    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let bodyText = paramMap["body"] as? String {
            self.bodyTextLabel.text = RSApplicationDelegate.localizedString(bodyText)
        }
        
    }
    
    open override func configure<T>(config: T) where T : RSTextCardCollectionViewCellConfiguration {
        super.configure(config: config)
        
        if let bodyText = config.body {
            self.bodyTextLabel.text = RSApplicationDelegate.localizedString(bodyText)
        }
    }
    
}


