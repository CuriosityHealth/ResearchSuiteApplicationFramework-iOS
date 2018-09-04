//
//  RSMarkdownCardCollectionViewCell.swift
//  Pods
//
//  Created by James Kizer on 6/5/18.
//

import UIKit

open class RSMarkdownCardCollectionViewCell: RSCardCollectionViewCell, RSCollectionViewCellGenerator {
    
    open class var identifier: String {
        return "markdownCardCell"
    }
    
    open class var collectionViewCellClass: AnyClass {
        return RSMarkdownCardCollectionViewCell.self
    }
    
    open var bodyTextView: UITextView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bodyTextView = UITextView()
        self.bodyTextView.dataDetectorTypes = .all
        self.bodyTextView.isEditable = false
        self.bodyTextView.isScrollEnabled = false
        self.bodyTextView.isSelectable = false
        
        let bodyStackView = UIStackView()
        self.contentStackView.addArrangedSubview(bodyStackView)
        
        bodyStackView.axis = .horizontal
        bodyStackView.spacing = 8.0
        
        bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        bodyStackView.addArrangedSubview(self.bodyTextView)
        bodyStackView.addArrangedSubview(RSCollectionViewCell.spacingView(axis: .horizontal))
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        
        self.bodyTextView.text = nil
        
        super.prepareForReuse()
        
    }
    
    override open func configure(paramMap: [String : Any]) {
        
        super.configure(paramMap: paramMap)
        
        if let bodyText = paramMap["body"] as? NSAttributedString {
            self.bodyTextView.attributedText = bodyText
        }
        
    }
    
}
