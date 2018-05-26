//
//  RSCalendarLayoutViewController.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import ReSwift
import Gloss
import LS2SDK
import FSCalendar

open class RSCalendarLayoutViewController: UIViewController, StoreSubscriber, RSSingleLayoutViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate  {
    
    
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
    
    var calendarLayout: RSCalendarLayout! {
        return self.layout as! RSCalendarLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var hasAppeared: Bool = false
    
    var calendarDataSource: RSCollectionDataSource?
    
    var datapointsByDate: [Date: [LS2Datapoint]]? = nil
    //    var classifiedDatapoints: [UUID: RSCalendarDatapointClass]? = nil
    //    var datapointsByClassAndDate: [Date: [RSCalendarDatapointClass: [LS2Datapoint]]]? = nil
    var datapointClassifier: RSDatapointClassifier!
    var calendar: Calendar!
    
//    var tableViewDataSource: RSCollectionDataSource?
    var tableViewDatapoints: [LS2Datapoint]?
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewCellManager: RSCollectionViewCellManager!
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendarView, action: #selector(self.calendarView.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButtons = self.layout.rightNavButtons {
            
            let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
                button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
            }
            
            let rightBarButtons = rightButtons.compactMap { (layoutButton) -> UIBarButtonItem? in
                return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap)
            }
            
            self.navigationItem.rightBarButtonItems = rightBarButtons

        }
        
        self.store?.subscribe(self)
        
        self.calendar = Calendar(identifier: .gregorian)
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.appearance.eventDefaultColor = UIColor.red
        self.calendarView.scope = .week
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        //        self.tableView.dataSource = self
        //        self.tableView.delegate = self
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.collectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        //add top border to table view
        //        CALayer *TopBorder = [CALayer layer];
        //        TopBorder.frame = CGRectMake(0.0f, 0.0f, myview.frame.size.width, 3.0f);
        //        TopBorder.backgroundColor = [UIColor redColor].CGColor;
        //        [myview.layer addSublayer:TopBorder];
        
        let border = CALayer()
        border.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: 1.0)
        
        self.collectionView.layer.addSublayer(border)
        self.collectionView!.backgroundColor = UIColor.groupTableViewBackground
        
        self.collectionViewCellManager = RSApplicationDelegate.appDelegate.collectionViewCellManager
        self.collectionViewCellManager.registerCellsFor(collectionView: self.collectionView!)
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout,
            let window = UIApplication.shared.windows.first {
            flowLayout.estimatedItemSize = CGSize(width: window.frame.size.width, height: window.frame.size.width)
        }
        
        //        self.updateDataSource(firstTime: true, filterWindow: nil)
        
        //        if self.mapLayout.hidesFilterControls {
        //            self.filterControlsView.isHidden = true
        //        }
        //        else {
        //            self.windowLocationSlider.minimumValue = 0.0
        //            self.windowLocationSlider.maximumValue = 1.0
        //            self.windowLocationSlider.value = 1.0
        //
        //            self.windowSizeSlider.minimumValue = Float(RSMapLayoutFilterWindowLength.oneMinute.rawValue)
        //            self.windowSizeSlider.maximumValue = Float(RSMapLayoutFilterWindowLength.allTime.rawValue)
        //            self.windowSizeSlider.value = Float(RSMapLayoutFilterWindowLength.allTime.rawValue)
        //        }
        //
        //        self.updateWindow(filter: false)
        
        self.layoutDidLoad()
    }
    
    
    deinit {
        self.store?.unsubscribe(self)
        //        self.notificationToken?.invalidate()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.calendarDataSource == nil {
            self.updateCalendarDataSource(firstTime: true)
            if let today = self.calendarView.today {
                self.updateTableViewDataSource(date: today)
            }
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
    
    func date(for datapoint: LS2Datapoint) -> Date? {
        //first classify datapoint
        guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint) else {
            return nil
        }
        
        return datapointClass.dateSelector(datapoint)
    }
    
    func groupDatapointsByDate(datasource: RSCollectionDataSource) -> [Date: [LS2Datapoint]]? {
        
        guard let array = datasource.toArray() else {
            return nil
        }
        
        
        //not all datapoints shoudl use the same date
        //i.e., some datapoints might use the provenance date for calendar ./ sorting,
        //but other dates
        let dateMap: [Date: [LS2Datapoint]] = Dictionary.init(grouping: array, by: { (datapoint) -> Date in
            
            guard let date = self.date(for: datapoint) else {
                assertionFailure("Could not generate date. What can we do here?")
                return Date.distantPast
            }
            
            return self.calendar.startOfDay(for: date)
            
        })
        
        
        return dateMap
    }
    
    //    func classifyDatapoints(datasource: RSRealmCollectionLayoutViewControllerDataSource) -> [UUID: RSCalendarDatapointClass]? {
    //
    //        guard let array = datasource.toArray() else {
    //            return nil
    //        }
    //
    //        guard let state = self.state else {
    //            return nil
    //        }
    //
    //        let context = self.context()
    //
    //        let mappingFunc: (RSCalendarDatapointClass) -> (RSCalendarDatapointClass, NSPredicate)? = { datapointClass in
    //
    //            guard let predicate = RSPredicateManager.generatePredicate(predicate: datapointClass.predicate, state: state, context: context) else {
    //                return nil
    //            }
    //
    //            return (datapointClass, predicate)
    //        }
    //
    //        //generate predicates, n= number of classes
    //        let pairs: [(RSCalendarDatapointClass, NSPredicate)] = self.calendarLayout.datapointClasses.compactMap { mappingFunc($0) }
    //        let classToPredicateMap: [RSCalendarDatapointClass: NSPredicate] = Dictionary(uniqueKeysWithValues: pairs)
    //
    //        //filter datapoints for each class, n*m
    //        let classToDatapointsMap: [RSCalendarDatapointClass: [LS2Datapoint]] = classToPredicateMap.mapValues { (predicate) -> [LS2Datapoint] in
    //
    //            return (array as NSArray).filtered(using: predicate) as! [LS2Datapoint]
    //
    //        }
    //
    //        var datapointIDToClassMap: [UUID: RSCalendarDatapointClass] = [:]
    //        classToDatapointsMap.forEach { (pair) in
    //            let datapointClass = pair.key
    //            pair.value.forEach({ (datapoint) in
    //
    //                if let datapointID = datapoint.header?.id {
    //                    assert(datapointIDToClassMap[datapointID] == nil, "Classes must be mutually exclusive")
    //                    datapointIDToClassMap[datapointID] = datapointClass
    //                }
    //
    //            })
    //        }
    //
    //
    //
    //        return datapointIDToClassMap
    //
    //    }
    
    func updateTableViewDataSource(date: Date) {
        
//        self.tableViewDataSource = nil
        
        //we will want to sort these based on class specific date selector
        
        let datapoints: [LS2Datapoint] = self.datapointsByDate?[date] ?? []

        let pairs: [(LS2Datapoint, Date)] = datapoints.compactMap { (datapoint) -> (LS2Datapoint, Date)? in
            guard let date = self.date(for: datapoint) else {
                return nil
            }
            
            return (datapoint, date)
        }
        
        let ascending = true

        let sortedDatapoints: [LS2Datapoint] = pairs.sorted(by: { (pairA, pairB) -> Bool in
            return ascending ? pairA.1 < pairB.1 : pairA.1 > pairB.1
        }).map { $0.0 }
        
        self.tableViewDatapoints = sortedDatapoints
        
        
        self.collectionView.reloadData()
//
//        //dont remove these here
//        //        self.mapView.removeAnnotations(self.annotations.compactMap({$0}))
//
//        let sortSettings = self.calendarLayout.dataSource.sortSettings
//        guard let rsPredicate = self.calendarLayout.dataSource.predicate,
//            let state = self.store?.state,
//            let dataSource = RSStateSelectors.getDataSource(state, for: self.calendarLayout.dataSource.dataSourceIdentifier),
//            let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: self.context()) else {
//                return
//        }
//
//        let startingDate = date
//        let endingDate = date.addingTimeInterval(24.0 * 60.0 * 60.0)
//
//        let substitutions: [String: Any] = [
//            "startingDate": startingDate,
//            "endingDate": endingDate
//        ]
//
//        let datePredicate = NSPredicate(format: "apSourceCreationDateTime >= $startingDate AND apSourceCreationDateTime <= $endingDate").withSubstitutionVariables(substitutions)
//
//        let readyCallback: (RSCollectionDataSource) -> () = { [unowned self] collectionDataSource in
//
//            self.collectionView.reloadData()
//
//        }
//
//        let updateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { [unowned self] collectionDataSource, deletions, insertions, modifications in
//            self.collectionView.reloadData()
//        }
//
//        let predicates: [NSPredicate] = [predicate, datePredicate]
//
//        self.tableViewDataSource = dataSource.getCollectionDataSource(
//            predicates: predicates,
//            sortSettings: sortSettings,
//            readyCallback: readyCallback,
//            updateCallback: updateCallback
//        )
        
//        self.tableViewDataSource = RSRealmCollectionLayoutViewControllerDataSource(
//            predicates: predicates,
//            sortSettings: sortSettings,
//            readyCallback: readyCallback,
//            updateCallback: updateCallback
//        )
    }
    
    func updateCalendarDataSource(firstTime: Bool) {
        
        self.calendarDataSource = nil
        
        //dont remove these here
        //        self.mapView.removeAnnotations(self.annotations.compactMap({$0}))
        
        let sortSettings = self.calendarLayout.dataSource.sortSettings
        guard let rsPredicate = self.calendarLayout.dataSource.predicate,
            let state = self.store?.state,
            let dataSource = RSStateSelectors.getDataSource(state, for: self.calendarLayout.dataSource.dataSourceIdentifier),
            let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: self.context()) else {
                return
        }
        
        self.datapointClassifier = RSDatapointClassifier.createClassifier(datapointClasses: self.calendarLayout.datapointClasses, state: state, context: self.context())
        
        let readyCallback: (RSCollectionDataSource) -> () = { [unowned self] collectionDataSource in
            
            guard let calendarDataSource = self.calendarDataSource else {
                return
            }
            
            self.datapointsByDate = self.groupDatapointsByDate(datasource: calendarDataSource)
            
            self.calendarView.reloadData()
            
            if let selectedDate: Date = self.calendarView.selectedDate ?? self.calendarView.today {
                self.updateTableViewDataSource(date: selectedDate)
            }
        }
        
        let updateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { [unowned self] collectionDataSource, deletions, insertions, modifications in
            
            guard let calendarDataSource = self.calendarDataSource else {
                return
            }
            
            self.datapointsByDate = self.groupDatapointsByDate(datasource: calendarDataSource)
            
            self.calendarView.reloadData()
            
            if let selectedDate: Date = self.calendarView.selectedDate ?? self.calendarView.today {
                self.updateTableViewDataSource(date: selectedDate)
            }
            
        }
        
//        let predicates: [NSPredicate] = [predicate].compactMap({ $0 })
        
        self.calendarDataSource = dataSource.getCollectionDataSource(
            predicates: [predicate],
            sortSettings: sortSettings,
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
        
//        self.calendarDataSource = RSRealmCollectionLayoutViewControllerDataSource(
//            predicates: predicates,
//            sortSettings: sortSettings,
//            readyCallback: readyCallback,
//            updateCallback: updateCallback
//        )
    }
    
    open func newState(state: RSState) {
        self.state = state
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            self.processAction(action: action)
        })
        
    }
    
    open func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                self.processAction(action: action)
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
    
    func classMapForDate(date: Date) -> [RSCalendarDatapointClass: [LS2Datapoint]] {
        
        guard let datapointsForDate = self.datapointsByDate?[date] else {
            return [:]
        }
        
        let classifiedDatapoints: [(LS2Datapoint, RSCalendarDatapointClass)] = datapointsForDate.compactMap { (datapoint) -> (LS2Datapoint, RSCalendarDatapointClass)? in
            
            guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint) as? RSCalendarDatapointClass else {
                return nil
            }
            
            return (datapoint, datapointClass)
        }
        
        let classMap: [RSCalendarDatapointClass: [(LS2Datapoint, RSCalendarDatapointClass)]] = Dictionary.init(grouping: classifiedDatapoints) { (pair) -> RSCalendarDatapointClass in
            return pair.1
        }
        
        return classMap.mapValues({ (pairs) -> [LS2Datapoint] in
            return pairs.map({ $0.0 })
        })
    }
    
    //MARK: Calendar Stuff
    open func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return self.classMapForDate(date: date).keys.count
    }
    
    open func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        return UIColor.blue
    }
    
    open func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let classMap = self.classMapForDate(date: date)
        
        let classes = classMap.keys.sorted { (first, second) -> Bool in
            return first.order < second.order
        }
        
        let classColors = classes.compactMap { (datapointClass) -> UIColor? in
            
            guard let colorJSON: JSON = "eventColor" <~~ datapointClass.calendarAppearance,
                let state = self.state,
                let color: UIColor = RSValueManager.processValue(jsonObject: colorJSON, state: state, context: self.context())?.evaluate() as? UIColor else {
                    return nil
            }
            
            return color
        }
        
        return classColors
    }
    
    open func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        debugPrint(date)
        self.updateTableViewDataSource(date: date)
        
    }
    
    open func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.collectionView.contentOffset.y <= -self.collectionView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendarView.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    
    //MARK: CollectionView Stuff
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        collectionView.deselectRow(at: indexPath, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
        
//        guard let dataSource = self.tableViewDataSource,
//            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
//                return
//        }
        
        guard let datapoints = self.tableViewDatapoints else {
            return
        }
        
        //note that we need to filter datapoints prior to indexing into the array
        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
        
        let datapoint:LS2Datapoint = filteredDatapoints[indexPath.row]
        
        guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint) as? RSCalendarDatapointClass,
            let datapointJSON = datapoint.toJSON()  else {
                return
        }
        
        let onTapActions: [JSON] = datapointClass.onTapActions
        onTapActions.forEach { (action) in
            self.processAction(action: action, extraContext: ["selected": datapointJSON as AnyObject])
        }
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
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        
        
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicCollectionViewCell", for: indexPath) as! RSBasicCollectionViewCell
        //        cell.setCellWidth(width: collectionView.bounds.width)
        
        //        guard let dataSource = self.tableViewDataSource,
        //            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
        //                return self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
        //        }
        //
        //        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
        //
        //        let datapoint:LS2Datapoint = filteredDatapoints[indexPath.row]
        //
        //        guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint) as? RSCalendarDatapointClass,
        //            let cell = self.collectionViewCellManager.cell(cellIdentifier: datapointClass.cellIdentifier, collectionView: collectionView, indexPath: indexPath) else {
        //            return self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
        //        }
        //
        //        let cellIdentifier = datapointClass.cellIdentifier
        //
        //        guard let datapointJSON = datapoint.toJSON(),
        //            let state = self.state,
        //            let paramMap = self.createParameterMap(datapoint: datapoint, mapping: datapointClass.cellMapping) else {
        //                return cell
        //        }
        
//        guard let dataSource = self.tableViewDataSource,
//            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
//                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
//                cell.setCellWidth(width: collectionView.bounds.width)
//                return cell
//        }
        
        guard let datapoints = self.tableViewDatapoints else {
            let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
            cell.setCellWidth(width: collectionView.bounds.width)
            return cell
        }
        
        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
        
        let datapoint:LS2Datapoint = filteredDatapoints[indexPath.row]
        
        guard let datapointClass = self.datapointClassifier.classifyDatapoint(datapoint: datapoint),
            let cell = self.collectionViewCellManager.cell(cellIdentifier: datapointClass.cellIdentifier, collectionView: collectionView, indexPath: indexPath) else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: collectionView.bounds.width)
                return cell
        }
        
        cell.setCellWidth(width: collectionView.bounds.width)
        
        guard let paramMap = self.createParameterMap(datapoint: datapoint, mapping: datapointClass.cellMapping) else {
            return cell
        }
        
        cell.configure(paramMap: paramMap)
        
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        return self.visibleLayoutItems.count
        
//        guard let dataSource = self.tableViewDataSource,
//            let datapoints: [LS2Datapoint] = dataSource.toArray() else {
//                return 0
//        }
        
        guard let datapoints = self.tableViewDatapoints else {
            return 0
        }
        
        let filteredDatapoints = datapoints.filter { self.datapointClassifier.classifyDatapoint(datapoint: $0) != nil }
        
        return filteredDatapoints.count
    }
    
}
