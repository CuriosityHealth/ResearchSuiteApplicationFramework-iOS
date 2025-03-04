//
//  RSLicenseViewController.swift
//  Pods
//
//  Created by James Kizer on 1/22/19.
//

import UIKit
import SnapKit
import ResearchSuiteExtensions
import SwiftyMarkdown

open class RSLicenseViewController: UIViewController {

//    public struct AcknowledgementItem {
//        let title: String
//        let shortLicense: String
//        let longLicense: String
//    }
//
//    public struct Acknowledgements {
//        let title: String
//        let text: String
//        let items: [AcknowledgementItem]
//    }
//
//    public static func getAcknowledgements(plistPath: String) -> Acknowledgements? {
//
//        guard let plistDict = NSDictionary(contentsOfFile: plistPath),
//            let acknowledgements = plistDict["PreferenceSpecifiers"] as? [[String:String]],
//            let head = acknowledgements.first,
//            let title = head["Title"],
//            let text = head["FooterText"] else {
//            return nil
//        }
//
//        let items: [AcknowledgementItem] = acknowledgements.dropFirst().compactMap({ itemDict in
//
//            guard let title = itemDict["Title"],
//                let shortLicense = itemDict["License"],
//                let longLicense = itemDict["FooterText"] else {
//                    return nil
//            }
//
//            return AcknowledgementItem(title: title, shortLicense: shortLicense, longLicense: longLicense)
//
//        })
//
//        return Acknowledgements(title: title, text: text, items: items)
//
//    }
    
    public static func convertMarkdownFileToAttributedString(markdownFilePath: String) -> NSAttributedString? {
        
        
        guard let url = URL(string: markdownFilePath),
            let markdownString = RSHelpers.getString(forURL: url) else {
            return nil
        }
        
        let md = SwiftyMarkdown(string: markdownString)
        //        md.h1.fontName = UIFont.preferredFont(forTextStyle: .title1).fontName
        
        let h1Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 35.0, weight: UIFont.Weight.light)
        
        md.h1.fontSize = h1Font.pointSize
        md.h1.fontName = h1Font.fontName
        
        let h2Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 32.0, weight: UIFont.Weight.light)
        
        md.h2.fontSize = h2Font.pointSize
        md.h2.fontName = h2Font.fontName
        
        let h3Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 28.0)
        
        md.h3.fontSize = h3Font.pointSize
        md.h3.fontName = h3Font.fontName
        
        let h4Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 24.0)
        
        md.h4.fontSize = h4Font.pointSize
        md.h4.fontName = h4Font.fontName
        
        let h5Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 20.0)
        
        md.h5.fontSize = h5Font.pointSize
        md.h5.fontName = h5Font.fontName
        
        let h6Font = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.subheadline, defaultSize: 15.0, typeAdjustment: 17.0)
        
        md.h6.fontSize = h6Font.pointSize
        md.h6.fontName = h6Font.fontName
        
        let bodyFont = RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.body, defaultSize: 17.0, typeAdjustment: 14.0)
        
        md.body.fontSize = bodyFont.pointSize
        md.body.fontName = bodyFont.fontName
        
        
        let attributedString = NSMutableAttributedString(attributedString: md.attributedString())
        
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attributes, range, finish) in
            
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {
                return
            }
            
            
//            let newFont: UIFont = {
//                print(font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.traits])
//                if let traits = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.traits] as? [UIFontDescriptor.TraitKey: Any],
//                    let weightValue = traits[UIFontDescriptor.TraitKey.weight] as? NSNumber {
//                    let weight = UIFont.Weight(CGFloat(weightValue.floatValue))
//                    return UIFont.systemFont(ofSize: font.pointSize, weight: weight)
//                }
//                else {
//                    
//                }
//            }()
            let newFont = UIFont.systemFont(ofSize: font.pointSize)
            let newAttributes = attributes.merging([NSAttributedString.Key.font: newFont]) { (first, second) -> Any in
                second
            }
            attributedString.setAttributes(newAttributes, range: range)
            
        }
        
        return attributedString
        
    }

    open var acknowledgementsFilePath: String?
    private var textView: UITextView!
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor.white
        if let filePath = self.acknowledgementsFilePath,
            let attributedString = RSLicenseViewController.convertMarkdownFileToAttributedString(markdownFilePath: filePath) {
            
            let textView = UITextView()
            textView.isEditable = false
            textView.attributedText = attributedString
            self.view.addSubview(textView)
            
            let tabBarShown: Bool = {
                if let tabBarController = self.tabBarController {
                    return !tabBarController.tabBar.isHidden
                }
                else {
                    return false
                }
            }()
            
            textView.snp.makeConstraints { (make) in
                
                if #available(iOS 11.0, *) {
                    //Bottom guide
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin)
                    //Top guide
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
                    //Leading guide
                    make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leadingMargin)
                    //Trailing guide
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin)
                    
                } else {
                    make.top.equalTo(self.topLayoutGuide.snp.bottom)
                    make.left.equalTo(view)
                    make.right.equalTo(view)
                    
                    if tabBarShown {
                        make.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-44)
                    }
                    else {
                        make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
                    }
                }
                
                
                
            }
            
            textView.setContentOffset(CGPoint.zero, animated: false)
            
            self.textView = textView
            
        }
        

    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print(self.textView.contentOffset)
    }
    
}
