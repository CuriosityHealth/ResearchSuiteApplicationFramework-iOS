//
//  RSLayoutManager-old.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift

//public class RSLayoutManager: NSObject {
//
//    let layoutGenerators: [RSLayoutGenerator]
//
//    public init(
//        layoutGenerators: [RSLayoutGenerator]?
//    ) {
//        self.layoutGenerators = layoutGenerators ?? []
//        super.init()
//    }
//
//    public func generateLayout(layout: RSLayout, store: Store<RSState>) -> RSLayout? {
//        for layoutGenerator in layoutGenerators {
//            if layoutGenerator.supportsType(type: layout.type),
//                let layoutVC = layoutGenerator.generateLayout(jsonObject: layout.element, store: store, layoutManager: self),
//                let _ = layoutVC as? RSLayoutViewControllerProtocol {
//                return layoutVC
//            }
//        }
//        return nil
//    }
//}
