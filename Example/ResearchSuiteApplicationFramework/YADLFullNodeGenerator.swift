//
//  YADLFullNodeGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchSuiteApplicationFramework
import Gloss
import ResearchKit
import sdlrkx

open class YADLFullNodeGenerator: RSStepTreeNodeGenerator {
    
    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
        
        guard let yadlFullDescriptor = YADLFullStepDescriptor(json: jsonObject) else {
            return nil
        }
        
        let textChoices: [ORKTextChoice] = yadlFullDescriptor.choices.flatMap { (choice) -> ORKTextChoice? in
            RKXTextChoiceWithColor(text: choice.text, value: choice.value as NSCoding & NSCopying & NSObjectProtocol, color: choice.color)
        }
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        
        let children = yadlFullDescriptor.items.flatMap({ (item) -> RSStepTreeLeafNode? in
            guard let image = UIImage(named: item.imageTitle)
                else {
                    assertionFailure("Cannot find image named \(item.imageTitle)")
                    return nil
            }
            
            let leafNode = RSStepTreeLeafNode(
                identifier: item.identifier,
                identifierPrefix: "\(identifierPrefix).\(yadlFullDescriptor.identifier)",
                type: "yadl_full_item",
                stepGenerator: { (rstb, identifierPrefix) -> ORKStep? in
                    let step = YADLFullAssessmentStep(
                        identifier: "\(identifierPrefix).\(item.identifier)",
                        title: item.description,
                        text: yadlFullDescriptor.text,
                        image: image,
                        answerFormat: answerFormat
                    )
                    step.isOptional = yadlFullDescriptor.optional
                    return step
            })
            
            return leafNode
        })

        let node = RSStepTreeBranchNode(
            identifier: yadlFullDescriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: yadlFullDescriptor.type,
            children: children,
            navigationRules: nil,
            resultTransforms: nil
        )
        
        return node
        
    }
    
    public static func supportsType(type: String) -> Bool {
        return "YADLFullAssessment" == type
    }

}
