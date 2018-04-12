//
//  RSLayoutManager.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
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
