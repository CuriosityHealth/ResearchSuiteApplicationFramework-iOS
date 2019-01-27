//
//  RSCollectionViewCellManager.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit

public protocol RSCollectionViewCellGenerator {
    //    static func supportsType(type: String) -> Bool
    //    static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout?
    static var identifier: String { get }
    static var collectionViewCellClass: AnyClass { get }
}



open class RSCollectionViewCellManager: NSObject {
    
    public let cellGenerators: [RSCollectionViewCellGenerator.Type]
    
    //init
    public init(cellGenerators: [RSCollectionViewCellGenerator.Type]?) {
        self.cellGenerators = cellGenerators ?? []
        super.init()
    }
    
    //regiter cells
    open func registerCellsFor(collectionView: UICollectionView) {
        self.cellGenerators.forEach { (cellGenerator) in
            collectionView.register(cellGenerator.collectionViewCellClass, forCellWithReuseIdentifier: cellGenerator.identifier)
        }
        
        collectionView.register(RSCollectionViewCell.self, forCellWithReuseIdentifier: "default")
    }
    
    open func defaultCellFor(collectionView: UICollectionView, indexPath: IndexPath) -> RSCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! RSCollectionViewCell
    }
    
    open func cell(cellIdentifier: String, collectionView: UICollectionView, indexPath: IndexPath) -> RSCollectionViewCell? {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? RSCollectionViewCell
    }
    
}
