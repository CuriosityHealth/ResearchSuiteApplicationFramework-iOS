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
    let maxLines: Int
    
    public init(
        icon: String?,
        title: String?,
        subtitle: String?,
        body: String?,
        maxLines: Int = 0
        ) {
        self.body = body
        self.maxLines = maxLines
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
    open var bodyStackView: UIStackView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bodyTextLabel = UILabel()
        self.bodyTextLabel.numberOfLines = 0
        
        self.bodyStackView = UIStackView()
        
        
        bodyStackView.axis = .horizontal
        bodyStackView.spacing = 8.0
        
//        self.bodyTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        self.bodyTextLabel.setContentHuggingPriority(.required, for: .vertical)
//        self.bodyStackView.setContentCompressionResistancePriority(.required, for: .vertical)
//        self.bodyStackView.setContentHuggingPriority(.required, for: .vertical)
        
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        
        self.bodyTextLabel.text = nil
        self.bodyStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        self.contentStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        
        super.prepareForReuse()
        
    }

    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let bodyText = paramMap["body"] as? String {
            
            self.bodyTextLabel.numberOfLines = (paramMap["maxLines"] as? Int) ?? 0
            
            self.bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            self.bodyStackView.addArrangedSubview(self.bodyTextLabel)
            self.bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            
            self.bodyTextLabel.text = RSApplicationDelegate.localizedString(bodyText)
            
            self.contentStackView.addArrangedSubview(self.bodyStackView)
            
        }
        else {
            self.contentStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .vertical))
        }
        
    }
    
    open override func configure(config: RSCollectionViewCellConfiguration) {
        super.configure(config: config)
        
        guard let typedConfig = config as? RSTextCardCollectionViewCellConfiguration else {
            return
        }
        
        if let bodyText = typedConfig.body {
            self.bodyTextLabel.numberOfLines = typedConfig.maxLines
            self.bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            self.bodyStackView.addArrangedSubview(self.bodyTextLabel)
            self.bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
            
            self.bodyTextLabel.text = RSApplicationDelegate.localizedString(bodyText)
            
            self.contentStackView.addArrangedSubview(self.bodyStackView)
            
        }
        else {
            self.contentStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .vertical))
        }
    }
    
}


