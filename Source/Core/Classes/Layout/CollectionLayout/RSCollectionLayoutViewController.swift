//
//  RSCollectionLayoutViewController.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import ReSwift
import Gloss
import RealmSwift
import LS2SDK
import ResearchSuiteExtensions

open class RSCollectionLayoutViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, StoreSubscriber, RSSingleLayoutViewController {
    
    static let TAG = "RSCollectionLayoutViewController"
    
    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
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
    
    var collectionLayout: RSCollectionLayout! {
        return self.layout as! RSCollectionLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    //    var visibleLayoutItems: [RSListItem] = []
    var hasAppeared: Bool = false
    //    var locationEvents: Results<LS2RealmDatapoint>?
    //    var notificationToken: NotificationToken? = nil
    
//    var dataSource: RSRealmCollectionLayoutViewControllerDataSource?
    var collectionDataSource: RSCollectionDataSource?
    var datapointClassifier: RSDatapointClassifier!
    
    var collectionViewCellManager: RSCollectionViewCellManager!
    var logger: RSLogger?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButton = self.layout.navButtonRight {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightButton.title, style: .plain, target: self, action: #selector(tappedRightBarButton))
        }
        
        self.store?.subscribe(self)
        
        // Register cell classes
        self.collectionViewCellManager = RSApplicationDelegate.appDelegate.collectionViewCellManager
        self.collectionViewCellManager.registerCellsFor(collectionView: self.collectionView!)
        self.collectionView?.isPrefetchingEnabled = false
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout,
            let window = UIApplication.shared.windows.first {
            
            //estimate square items
            flowLayout.estimatedItemSize = CGSize(width: window.frame.size.width, height: window.frame.size.width)
        }
        
        //        self.collectionView!.backgroundColor = UIColor.blue
        
        //        self.collectionView.layoutDel
        
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
    
    func updateDataSource() {
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource")
        
        self.collectionDataSource = nil
        
        let sortSettings = self.collectionLayout.dataSource.sortSettings
        guard let rsPredicate = self.collectionLayout.dataSource.predicate,
            let state = self.store?.state,
            let dataSource = RSStateSelectors.getDataSource(state, for: self.collectionLayout.dataSource.dataSourceIdentifier),
            let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: self.context()) else {
                return
        }
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - creating classifier")
        self.datapointClassifier = RSDatapointClassifier.createClassifier(datapointClasses: self.collectionLayout.datapointClasses, state: state, context: self.context())
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - created classifier")
        
        let readyCallback: (RSCollectionDataSource) -> () = { collectionDataSource in
            self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - readyCallback")
            self.collectionView!.reloadData()
        }
        
        let updateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { collectionDataSource, deletions, insertions, modifications in
            
            self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "updateDataSource - updateCallback")
//            self.collectionView!.reloadData()
            
            self.collectionView!.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
            self.collectionView!.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0) }))
            self.collectionView!.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0) }))
            
            //            self.collectionView!.beginUpdates()
            //            self.collectionView!.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
            //                                      with: .automatic)
            //            self.collectionView!.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
            //                                      with: .automatic)
            //            self.collectionView!.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
            //                                      with: .automatic)
            //            self.collectionView!.endUpdates()
        }
        
        self.collectionDataSource = dataSource.getCollectionDataSource(
            predicates: [predicate],
            sortSettings: sortSettings,
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.collectionDataSource == nil {
            self.updateDataSource()
        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    @objc
    func tappedRightBarButton() {
        guard let button = self.layout.navButtonRight else {
            return
        }
        
        button.onTapActions.forEach { self.processAction(action: $0) }
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON, extraContext: [String : AnyObject]? = nil) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(extraContext: extraContext), store: store)
        }
    }
    
    open func newState(state: RSState) {
        self.state = state
    }
    
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
        let count = self.collectionDataSource?.count ?? 0
        //        let count = 5
        return count
    }
    
    open func createParameterMap(datapoint: LS2Datapoint, mapping: [String: JSON]) -> [String: Any]? {
        
        guard let datapointJSON = datapoint.toJSON(),
            let state = self.state else {
                return nil
        }
        
        let context = self.context(extraContext: ["element": datapointJSON as AnyObject])
        
        let mappingList:[(String, Any)] = mapping.compactMap({ (pair) -> (String, Any)? in
            guard let value = RSValueManager.processValue(jsonObject: pair.value, state: state, context: context)?.evaluate() else {
                return nil
            }
            
            return (pair.key, value)
        })
        
        return Dictionary.init(uniqueKeysWithValues: mappingList)
        
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "getting cell at indexPath \(indexPath)")
        
        guard let dataSource = self.collectionDataSource,
            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: collectionView.bounds.width)
                return cell
        }
        
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Filtering datapoints")
        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "datapoints filtered")
        
        let datapoint:LS2Datapoint = filteredDatapoints[indexPath.row]
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Generating cell")
        guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint),
            let cell = self.collectionViewCellManager.cell(cellIdentifier: datapointClass.cellIdentifier, collectionView: collectionView, indexPath: indexPath) else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: collectionView.bounds.width)
                return cell
        }
        
        cell.setCellWidth(width: collectionView.bounds.width)
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "Generating param map")
        guard let paramMap = self.createParameterMap(datapoint: datapoint, mapping: datapointClass.cellMapping) else {
            return cell
        }
        
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "configuring cell")
        cell.configure(paramMap: paramMap)
        self.logger?.log(tag: RSCollectionLayoutViewController.TAG, level: .info, message: "cell configured")
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let dataSource = self.collectionDataSource,
            let datapoint:LS2Datapoint = dataSource.get(for: indexPath.row),
            let datapointJSON = datapoint.toJSON(),
            let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint) else {
                return
        }
        
        let onTapActions = datapointClass.onTapActions
        
        onTapActions.forEach { (action) in
            self.processAction(action: action, extraContext: ["selected": datapointJSON as AnyObject])
        }
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
