//
//  RSDashboardLayoutViewController.swift
//  Pods
//
//  Created by James Kizer on 6/5/18.
//

import UIKit
import ReSwift
import Gloss
//import RealmSwift
import LS2SDK
import ResearchSuiteExtensions

open class RSDashboardLayoutViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, StoreSubscriber, RSSingleLayoutViewController {
    
    static let TAG = "RSDashboardLayoutViewController"
    
    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public let uuid: UUID = UUID()
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    var state: RSState?
    var lastState: RSState?
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }
    
    var dashboardLayout: RSDashboardLayout! {
        return self.layout as! RSDashboardLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var hasAppeared: Bool = false
    
    var collectionViewCellManager: RSCollectionViewCellManager!
    var logger: RSLogger?
    
    var visibleItems: [RSDashboardListItem]!
    
    
    open func initializeNavBar() {
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        if let rightButtons = self.layout.rightNavButtons {
            let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
                button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
            }
            
            let rightBarButtons = rightButtons.compactMap { (layoutButton) -> UIBarButtonItem? in
                return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
            }
            
            self.navigationItem.rightBarButtonItems = rightBarButtons
        }
        
    }
    
    open func reloadLayout() {
        
        self.initializeNavBar()
        self.collectionView?.reloadData()
        self.childLayoutVCs.forEach({$0.reloadLayout()})
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.initializeNavBar()
        
        self.store?.subscribe(self)
        self.state = self.store?.state
        
        // Register cell classes
        self.collectionViewCellManager = RSApplicationDelegate.appDelegate.collectionViewCellManager
        self.collectionViewCellManager.registerCellsFor(collectionView: self.collectionView!)
        self.collectionView?.isPrefetchingEnabled = false
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout,
            let window = UIApplication.shared.windows.first {
            let cellWidth = window.frame.size.width - (flowLayout.sectionInset.right + flowLayout.sectionInset.left)
            flowLayout.estimatedItemSize = CGSize(width: cellWidth, height: cellWidth)
            if #available(iOS 11.0, *) {
                flowLayout.sectionInsetReference = .fromSafeArea
            } else {
                //do nothing
            }
        }
        
        if let backgroundImage = self.dashboardLayout.backgroundImage {
            let imageView = UIImageView(image: backgroundImage)
            imageView.contentMode = .bottom
            self.collectionView!.backgroundView = imageView
        }
        
        if let backgroundColorJSON = self.dashboardLayout.backgroundColorJSON,
            let state = self.state,
            let backgroundColor = RSValueManager.processValue(jsonObject: backgroundColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            
            self.collectionView!.backgroundColor = backgroundColor
        }
        else {
            self.collectionView!.backgroundColor = UIColor.groupTableViewBackground
        }
        
        // Do any additional setup after loading the view.
        self.layoutDidLoad()
        
        self.logger = RSApplicationDelegate.appDelegate.logger
        
    }
    
    deinit {
        self.store?.unsubscribe(self)
        //        self.notificationToken?.invalidate()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateVisibleItems() {
        
        guard let state = self.store?.state else {
            return
        }
        
        self.visibleItems = self.dashboardLayout.items.filter({ (item) -> Bool in
            
            if let predicate = item.predicate {
                return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: self.context(extraContext: ["item": item]))
            }
            else {
                return true
            }
            
        })
        
    }
    
//    func updateDataSource() {
//
//        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource")
//
//        self.collectionDataSource = nil
//
//        let datapointClasses = self.collectionLayout.datapointClasses
//        let dataSourceDescriptors: [RSCollectionDataSourceDescriptor] = datapointClasses.map { $0.dataSource }
//        guard let state = self.store?.state else {
//            return
//        }
//
//        //        let sortSettings = self.collectionLayout.dataSource.sortSettings
//        //        guard let rsPredicate = self.collectionLayout.dataSource.predicate,
//        //            let state = self.store?.state,
//        //            let dataSource = RSStateSelectors.getDataSource(state, for: self.collectionLayout.dataSource.dataSourceIdentifier),
//        //            let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: self.context()) else {
//        //                return
//        //        }
//
//        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - creating classifier")
//        //        self.datapointClassifier = RSOldDatapointClassifier.createClassifier(datapointClasses: self.collectionLayout.datapointClasses, state: state, context: self.context())
//        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - created classifier")
//
//        let readyCallback: (RSCollectionDataSource) -> () = { collectionDataSource in
//            self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - readyCallback")
//            self.collectionView!.reloadData()
//        }
//
//        let updateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { collectionDataSource, deletions, insertions, modifications in
//
//            self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - updateCallback")
//            //            self.collectionView!.reloadData()
//
//            self.collectionView!.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
//            self.collectionView!.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0) }))
//            self.collectionView!.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0) }))
//
//            //            self.collectionView!.beginUpdates()
//            //            self.collectionView!.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//            //                                      with: .automatic)
//            //            self.collectionView!.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//            //                                      with: .automatic)
//            //            self.collectionView!.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//            //                                      with: .automatic)
//            //            self.collectionView!.endUpdates()
//        }
//
//        let dataSourceManager: RSCollectionDataSourceManager = RSApplicationDelegate.appDelegate.collectionDataSourceManager
//
//        self.collectionDataSource = RSCompositeCollectionDataSource(
//            identifier: self.collectionLayout.identifier,
//            childDataSourceDescriptors: dataSourceDescriptors,
//            dataSourceManager: dataSourceManager,
//            state: state,
//            context: self.context(),
//            readyCallback: readyCallback,
//            updateCallback: updateCallback
//        )
//
//        //        self.collectionDataSource = dataSource.getCollectionDataSource(
//        //            identifier: self.collectionLayout.dataSource.identifier,
//        //            predicates: [predicate],
//        //            sortSettings: sortSettings,
//        //            readyCallback: readyCallback,
//        //            updateCallback: updateCallback
//        //        )
//
//    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.visibleItems == nil {
            self.updateVisibleItems()
        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON, extraContext: [String : AnyObject]? = nil) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(extraContext: extraContext), store: store)
        }
    }
    
    public func handleNewStateActions(state: RSState, lastState: RSState) {
        
        let shouldRunActions = self.layout.onNewStateActions.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
        }
        
        if shouldRunActions {
            self.layout.onNewStateActions.actions.forEach { (actionJSON) in
                self.processAction(action: actionJSON)
            }
        }
        
    }
    
    open func newState(state: RSState) {
        
        guard let lastState = self.lastState else {
            self.lastState = state
            return
        }
        
        self.state = state
        
        self.handleNewStateActions(state: state, lastState: lastState)
        
        let shouldReload = self.dashboardLayout.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
        }
        
        if shouldReload {
            self.updateVisibleItems()
            self.collectionView?.reloadData()
        }
        
        self.lastState = state
        
        
        
    }
    
//    func datapointClass(for index: Int) -> RSDatapointClass? {
//        guard let compositeDataSource = self.collectionDataSource,
//            let childDataSource = compositeDataSource.dataSource(for: index) else {
//                return nil
//        }
//
//        return self.collectionLayout.datapointClasses.first(where: { (datapointClass) -> Bool in
//            return datapointClass.dataSource.identifier == childDataSource.identifier
//        })
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let count = self.visibleItems?.count ?? 0
        return count
    }
//
    open func createParameterMap(item: RSDashboardListItem) -> [String: Any]? {
        
        guard let state = self.store?.state else {
            return nil
        }
        
        let context = self.context()

        let mappingList:[(String, Any)] = item.cellMapping.compactMap({ (pair) -> (String, Any)? in
            guard let valueJSON = pair.value as? JSON,
                let value = RSValueManager.processValue(jsonObject: valueJSON, state: state, context: context)?.evaluate() else {
                return nil
            }

            return (pair.key, value)
        })

        return Dictionary.init(uniqueKeysWithValues: mappingList)
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
//        return cell
        
        self.logger?.log(tag: RSDashboardLayoutViewController.TAG, level: .info, message: "getting cell at indexPath \(indexPath)")

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
            cell.setCellWidth(width: collectionView.bounds.width)
            return cell
        }

        let cellWidth = collectionView.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
//
//        //        guard let dataSource = self.collectionDataSource,
//        //            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
//        //                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
//        //                cell.setCellWidth(width: cellWidth)
//        //                return cell
//        //        }
//
//
//        //        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Filtering datapoints")
//        //        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
//        //        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "datapoints filtered")
//        //
//        //        let datapoint:LS2Datapoint = filteredDatapoints[indexPath.row]
//
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Generating cell")
        let item = self.visibleItems[indexPath.row]
        
        guard let cell = self.collectionViewCellManager.cell(cellIdentifier: item.type, collectionView: collectionView, indexPath: indexPath) as? RSCardCollectionViewCell else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: cellWidth)
                return cell
        }

        cell.setCellWidth(width: cellWidth)
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Generating param map")
        
        guard let paramMap = self.createParameterMap(item: item) else {
            return cell
        }
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "configuring cell")
        cell.configure(paramMap: paramMap)
        
        if item.onTapActions.count > 0 {
            let onTap: (RSCollectionViewCell)->() = { [unowned self] cell in
                item.onTapActions.forEach({ (action) in
                    self.processAction(action: action)
                })
            }
            cell.onTap = onTap
        }
        else {
            cell.onTap = nil
        }
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "cell configured")

        if let cellTintJSON: JSON = "cellTint" <~~ item.element,
            let state = self.state,
            let color: UIColor = RSValueManager.processValue(jsonObject: cellTintJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            cell.setCellTint(color: color)
        }

        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        debugPrint("cell tapped at \(indexPath)")
        collectionView.deselectItem(at: indexPath, animated: true)
        
//        guard let dataSource = self.collectionDataSource,
//            let datapoint:LS2Datapoint = dataSource.get(for: indexPath.row),
//            let datapointJSON = datapoint.toJSON(),
//            let datapointClass = self.datapointClass(for: indexPath.row) else {
//                return
//        }
//        
//        let onTapActions = datapointClass.onTapActions
//        
//        onTapActions.forEach { (action) in
//            self.processAction(action: action, extraContext: ["selected": datapointJSON as AnyObject])
//        }
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            self.processAction(action: action)
        })
        
    }
    
    open func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                if let store = self.store {
                    store.processAction(action: action, context: ["layoutViewController":self], store: store)
                }
            })
        }
        
    }
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        self.matchedRoute = matchedRoute
    }
    
}
