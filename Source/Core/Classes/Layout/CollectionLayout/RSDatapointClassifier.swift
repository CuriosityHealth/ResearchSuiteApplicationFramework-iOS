//
//  RSDatapointClassifier.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import Gloss
import LS2SDK

open class RSDatapointClassifier: NSObject {
    
    private let classToPredicateMap: [RSDatapointClass: NSPredicate]
    
    // the classififer also memoizes results so that once a datapoint is classified,
    // it doesn;t have to be classified again
    private var datapointToClassMap: [UUID: RSDatapointClass]
    
    static func createClassifier(datapointClasses: [RSDatapointClass], state: RSState, context: [String : AnyObject]) -> RSDatapointClassifier {
        
        let mappingFunc: (RSDatapointClass) -> (RSDatapointClass, NSPredicate)? = { datapointClass in
            
            if let rsPredicate = datapointClass.predicate {
                guard let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: context) else {
                    return nil
                }
                
                return (datapointClass, predicate)
            }
            else {
                let predicate = NSPredicate(value: true)
                return (datapointClass, predicate)
            }
            
        }
        
        //generate predicates, n= number of classes
        let pairs: [(RSDatapointClass, NSPredicate)] = datapointClasses.compactMap { mappingFunc($0) }
        let classToPredicateMap: [RSDatapointClass: NSPredicate] = Dictionary(uniqueKeysWithValues: pairs)
        
        return RSDatapointClassifier(classToPredicateMap: classToPredicateMap)
    }
    
    init(classToPredicateMap: [RSDatapointClass: NSPredicate]) {
        
        self.classToPredicateMap = classToPredicateMap
        self.datapointToClassMap = [:]
        super.init()
        
    }
    
    open func classifyDatapoint(datapoint: LS2Datapoint) -> RSDatapointClass? {
        //check to see if memoized
        guard let header = datapoint.header else {
            return nil
        }
        
        if let datapointClass = self.datapointToClassMap[header.id] {
            return datapointClass
        }
        else {
            
            let matchingClasses = self.classToPredicateMap.compactMap { (pair) -> RSDatapointClass? in
                let array = NSArray(array: [datapoint]).filtered(using: pair.value)
                return (array.count == 1) ? pair.key : nil
            }
            
            //if we want, we can relax this constraint and rely on order of classes as priority
            assert(matchingClasses.count <= 1, "Datapoint matched more thab one class")
            
            if matchingClasses.count == 1,
                let matchingClass = matchingClasses.first {
                self.datapointToClassMap[header.id] = matchingClass
                return matchingClass
            }
            else {
                return nil
            }
            
        }
    }
    
}
