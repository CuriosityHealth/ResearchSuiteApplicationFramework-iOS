//
//  RSSchedulerDashboardAdaptor.swift
//  Pods
//
//  Created by James Kizer on 10/25/18.
//

import UIKit

open class RSSchedulerDashboardAdaptor: NSObject, RSDashboardAdaptor, RSSchedulerSubscriber {
    
    var collectionViewCellManager: RSCollectionViewCellManager! {
        return RSApplicationDelegate.appDelegate.collectionViewCellManager
    }
    
    weak var collectionView: UICollectionView?
    
    var items: [RSDashboardAdaptorItem] = []
    open var priorityCutoff: Int = 0
    
    //hold onto this in order to unsubscribe later
    weak var scheduler: RSScheduler?
    
    public init(scheduler: RSScheduler) {
        self.scheduler = scheduler
        super.init()
        scheduler.subscribe(self)
    }
    
    deinit {
        self.scheduler?.unsubscribe(self)
    }
    
    open func configure(collectionView: UICollectionView) {
        // Register cell classes
        self.collectionViewCellManager.registerCellsFor(collectionView: collectionView)
        collectionView.isPrefetchingEnabled = false
        collectionView.reloadData()
        self.collectionView = collectionView
    }
    
    open func dashboardItems(for events: [RSScheduleEvent]) -> [RSDashboardAdaptorItem] {
        return events
            .compactMap { ($0 as? RSDashboardAdaptorItemConvertible)?.toDashboardAdaptorItem() }
            .filter { $0.shouldPresentItem }
            .filter { $0.priority >= priorityCutoff }
            .sorted(by: { (first, second) -> Bool in
                return first.priority > second.priority
            })
    }
    
    open func newSchedulerEvents(
        scheduler: RSScheduler,
        events: [RSScheduleEvent],
        deletions: [Int],
        additions: [Int],
        modifications: [Int]
        ) {
        
        //first, we need to filter events by what should be shown in the dashboard
        //We only want to show events that are pending
        // - no start date or start date in the past
        // - if start date exists, check that window based on start + duration has not elapsed
        // - has not completed

        self.items = self.dashboardItems(for: events)
        
        self.collectionView?.reloadData()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
            cell.setCellWidth(width: collectionView.bounds.width)
            return cell
        }
        
        //get item at index path
        let item = self.items[indexPath.row]
        
        let cellWidth = collectionView.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        
        guard let store = RSApplicationDelegate.appDelegate.store,
            let cell = item.generateCell(store, store.state, collectionView, self.collectionViewCellManager, item, indexPath) else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: cellWidth)
                return cell
        }
        
        cell.setCellWidth(width: cellWidth)
        
        return cell
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
