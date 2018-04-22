//
//  RSFeedbackInputView.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/21/18.
//

import UIKit

protocol RSFeedbackInputViewDelegate: class {
    func onSubmit(feedbackText: String)
    func onCancel()
}

open class RSFeedbackInputView: UIView {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 16.0
    }
    
    weak var delegate: RSFeedbackInputViewDelegate?
    
    
    
    @IBOutlet weak var feedbackInputView: UITextView!

    @IBAction func onSubmitAction(_ sender: Any) {
        self.delegate?.onSubmit(feedbackText: self.feedbackInputView.text)
    }

    @IBAction func onCancelAction(_ sender: Any) {
        self.delegate?.onCancel()
    }
    
    
    
}
