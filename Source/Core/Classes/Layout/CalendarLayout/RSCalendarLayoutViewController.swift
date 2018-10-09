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
    
    var calendarDataSource: RSCompositeCollectionDataSource?
    
    var datapointIndicesByDate: [Date: [Int]]? = nil
    var calendar: Calendar!
    
    var tableViewDatapointIndices: [Int]?
    
    var filteredDatapointClasses: [String]!
    
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
    
    
    open func initializeNavBar() {
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        
        var rightBarButtonItems: [UIBarButtonItem] = []
        if let rightButtons = self.layout.rightNavButtons {
            
            let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
                button.layoutButton.onTapActions.forEach {
                    
                    let extraContext: [String : AnyObject] = {
                        if let selectedDate = self.calendarView.selectedDate ?? self.calendarView.today {
                            return ["selectedDate": selectedDate as AnyObject]
                        }
                        else {
                            return [:]
                        }
                    }()
                    
                    self.processAction(action: $0, extraContext: extraContext)
                    
                }
            }
            
            let rightBarButtons = rightButtons.compactMap { (layoutButton) -> UIBarButtonItem? in
                return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
            }
            
            rightBarButtonItems = rightBarButtonItems + rightBarButtons
        }
        
        if self.calendarLayout.datapointClasses.count > 1,
            let filterOptionsJSON = self.calendarLayout.filterOptions {
            
            let filterButton: UIBarButtonItem = {
                
                if let image: UIImage = {
                    guard let imageString: String = "image" <~~ filterOptionsJSON else {
                        return nil
                    }
                    
                    return UIImage(named: imageString)
                    }() {
                    return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.filterClicked(_:)))
                }
                else {
                    return UIBarButtonItem(title: RSApplicationDelegate.localizedString("Filter"), style: .plain, target: self, action:  #selector(self.filterClicked(_:)))
                }
                
            }()
            
            rightBarButtonItems = rightBarButtonItems + [filterButton]
            
        }
        
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
        
    }
    
    open func reloadLayout() {
        
        self.initializeNavBar()
        self.calendarView?.reloadData()
        self.collectionView?.reloadData()
        self.childLayoutVCs.forEach({$0.reloadLayout()})
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initializeNavBar()
        
        self.store?.subscribe(self)
        
        self.calendar = Calendar(identifier: .gregorian)
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        
        switch self.calendarLayout.calendarScope {
        case .alwaysExpanded:
            self.calendarView.scope = .month
        case .alwaysCollapsed:
            self.calendarView.scope = .week
        case .configurable:
            self.calendarView.scope = .week
            self.view.addGestureRecognizer(self.scopeGesture)
            self.collectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        }
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let border = CALayer()
        border.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: 1.0)
        
        self.collectionView.layer.addSublayer(border)
        self.collectionView!.backgroundColor = UIColor.groupTableViewBackground
        self.collectionView!.allowsSelection = false
        
        self.collectionViewCellManager = RSApplicationDelegate.appDelegate.collectionViewCellManager
        self.collectionViewCellManager.registerCellsFor(collectionView: self.collectionView!)
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout,
            let window = UIApplication.shared.windows.first {
            let cellWidth = window.frame.size.width - (flowLayout.sectionInset.right + flowLayout.sectionInset.left)
            flowLayout.estimatedItemSize = CGSize(width: cellWidth, height: cellWidth)
        }
        
        let defaultAccentColor = RSApplicationDelegate.appDelegate.applicationTheme?.navigationBarTitleColor ?? self.view.window?.tintColor
        
        let appearance = self.calendarView.appearance
        appearance.eventDefaultColor = defaultAccentColor
        appearance.headerTitleColor = defaultAccentColor
        appearance.weekdayTextColor = defaultAccentColor
        
        if let calendarAppearance = self.calendarLayout.calendarAppearance,
            let state = self.state {
            
            if let colorJSON = calendarAppearance.defaultEventColor,
                let color = RSValueManager.processValue(jsonObject: colorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                
                appearance.eventDefaultColor = color
                
            }
            
            if let colorJSON = calendarAppearance.headerColor,
                let color = RSValueManager.processValue(jsonObject: colorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                
                appearance.headerTitleColor = color
                appearance.weekdayTextColor = color
                
            }
            
        } 
        
        self.layoutDidLoad()
    }
    
    
    deinit {
        self.store?.unsubscribe(self)
        //        self.notificationToken?.invalidate()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.calendarDataSource == nil {
            self.filteredDatapointClasses = self.calendarLayout.datapointClasses.map {  $0.identifier  }
            self.updateCalendarDataSource(firstTime: true, includedDatapointClasses: self.filteredDatapointClasses)
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
    
    @objc func filterClicked(_ sender: UIBarButtonItem) {
        
        let vc = RSFilterPopoverTableViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        let items: [(RSFilterPopoverItem, Bool)] = self.calendarLayout.datapointClasses.map { datapointClass in
            let included = self.filteredDatapointClasses.contains(datapointClass.identifier)
            return (RSFilterPopoverItem(identifier: datapointClass.identifier, prompt: datapointClass.filterPrompt), included)
        }
        
        let onDismiss: ([(RSFilterPopoverItem, Bool)]?) -> () = { pairs in
            
            if let pairs = pairs {
                self.filteredDatapointClasses = pairs.filter { $0.1 }.map { $0.0.identifier }
                self.updateCalendarDataSource(firstTime: false, includedDatapointClasses: self.filteredDatapointClasses)
            }
            
            nav.dismiss(animated: true, completion: nil)
        }
        
        vc.onDismiss = onDismiss
        vc.update(items: items)
        
        present(nav, animated: true, completion: nil)
        
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    
    open func processAction(action: JSON, extraContext: [String : AnyObject]? = nil) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(extraContext: extraContext), store: store)
        }
    }
    
    func datapointClass(for index: Int) -> RSDatapointClass? {
        guard let compositeDataSource = self.calendarDataSource,
            let childDataSource = compositeDataSource.dataSource(for: index) else {
                return nil
        }
        
        return self.calendarLayout.datapointClasses.first(where: { (datapointClass) -> Bool in
            return datapointClass.dataSource.identifier == childDataSource.identifier
        })
    }
    
    func date(for datapointIndex: Int) -> Date? {
        guard let compositeDataSource = self.calendarDataSource,
            let datapoint = compositeDataSource.get(for: datapointIndex),
            let datapointClass = self.datapointClass(for: datapointIndex) else {
            return nil
        }
        
        return datapointClass.dateSelector(datapoint)
    }
    
    func groupIndicesByDate(datasource: RSCollectionDataSource) -> [Date: [Int]]? {
        
        guard let count = datasource.count else {
            return nil
        }
        
        let range = 0..<count

        //not all datapoints shoudl use the same date
        //i.e., some datapoints might use the provenance date for calendar ./ sorting,
        //but other dates
        let dateMap: [Date: [Int]] = Dictionary.init(grouping: range, by: { (index) -> Date in
            
            guard let date = self.date(for: index) else {
                assertionFailure("Could not generate date. What can we do here?")
                return Date.distantPast
            }
            
            return self.calendar.startOfDay(for: date)
            
        })
        
        
        return dateMap
    }
    
    func updateTableViewDataSource(date: Date) {
        
//        self.tableViewDataSource = nil
        
        //we will want to sort these based on class specific date selector
        
        let indices: [Int] = self.datapointIndicesByDate?[date] ?? []

        let pairs: [((Int,RSCollectionDataSourceElement), Date)] = indices.compactMap { (index) -> ((Int, RSCollectionDataSourceElement), Date)? in
            guard let date = self.date(for: index),
                let datapoint = self.calendarDataSource?.get(for: index) else {
                return nil
            }
            
            return ( (index,datapoint), date)
        }
        
        let ascending = true

        let sortedDatapoints: [(Int, RSCollectionDataSourceElement)] = pairs.sorted(by: { (pairA, pairB) -> Bool in
            return ascending ? pairA.1 < pairB.1 : pairA.1 > pairB.1
        }).map { $0.0 }
        
        self.tableViewDatapointIndices  = sortedDatapoints.map { $0.0 }
        
        self.collectionView.reloadData()

    }
    
    func updateCalendarDataSource(firstTime: Bool, includedDatapointClasses: [String]) {
        
        self.calendarDataSource = nil

        //take all the calsses
        let datapointClasses = self.calendarLayout.datapointClasses.filter( { includedDatapointClasses.contains($0.identifier) } )
        let dataSourceDescriptors: [RSCollectionDataSourceDescriptor] = datapointClasses.map { $0.dataSource }
        guard let state = self.store?.state else {
            return
        }

        let readyCallback: (RSCollectionDataSource) -> () = { [unowned self] collectionDataSource in
            
            guard let calendarDataSource = self.calendarDataSource else {
                return
            }
            
            self.datapointIndicesByDate = self.groupIndicesByDate(datasource: calendarDataSource)
            
            self.calendarView.reloadData()
            
            if let selectedDate: Date = self.calendarView.selectedDate ?? self.calendarView.today {
                self.updateTableViewDataSource(date: selectedDate)
            }
        }
        
        let updateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { [unowned self] collectionDataSource, deletions, insertions, modifications in
            
            guard let calendarDataSource = self.calendarDataSource else {
                return
            }
            
            self.datapointIndicesByDate = self.groupIndicesByDate(datasource: calendarDataSource)
            
            self.calendarView.reloadData()
            
            if let selectedDate: Date = self.calendarView.selectedDate ?? self.calendarView.today {
                self.updateTableViewDataSource(date: selectedDate)
            }
            
        }

        let dataSourceManager: RSCollectionDataSourceManager = RSApplicationDelegate.appDelegate.collectionDataSourceManager
        
        self.calendarDataSource = RSCompositeCollectionDataSource(
            identifier: self.calendarLayout.identifier,
            childDataSourceDescriptors: dataSourceDescriptors,
            dataSourceManager: dataSourceManager,
            state: state,
            context: self.context(),
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
        
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
    
    func classMapForDate(date: Date) -> [RSDatapointClass: [RSCollectionDataSourceElement]] {
        
        guard let indicesForDate = self.datapointIndicesByDate?[date] else {
            return [:]
        }
        
        let pairs: [(RSDatapointClass, Int)] = indicesForDate.compactMap({ index in
            
            guard let datapointClass = self.datapointClass(for: index) else {
                return nil
            }
            return (datapointClass, index)
            
        })
        
        let classifiedIndices: [RSDatapointClass: [(RSDatapointClass, Int)]] = Dictionary.init(grouping: pairs) { $0.0 }

        return classifiedIndices.mapValues({ (pairs) -> [RSCollectionDataSourceElement] in
            return pairs.compactMap({ (pair) -> RSCollectionDataSourceElement? in
                return self.calendarDataSource?.get(for: pair.1)
            })
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
            
            guard let cellTintJSON: JSON = datapointClass.cellTint,
                let state = self.state,
                let color: UIColor = RSValueManager.processValue(jsonObject: cellTintJSON, state: state, context: self.context())?.evaluate() as? UIColor else {
                    return nil
            }
            
            return color
        }
        
        return classColors
    }
    
    open func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
//        debugPrint(date)
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
    
    open func createParameterMap(datapoint: RSCollectionDataSourceElement, mapping: [String: JSON]) -> [String: Any]? {
        
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
        
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
            cell.setCellWidth(width: collectionView.bounds.width)
            return cell
        }
        
        let cellWidth = collectionView.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        
        guard let datapointIndices = self.tableViewDatapointIndices else {
            let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
            cell.setCellWidth(width: cellWidth)
            return cell
        }
        
        guard let datapointClass = self.datapointClass(for: datapointIndices[indexPath.row]),
            let datapoint = self.calendarDataSource?.get(for: datapointIndices[indexPath.row]),
            let cell = self.collectionViewCellManager.cell(cellIdentifier: datapointClass.cellIdentifier, collectionView: collectionView, indexPath: indexPath) else {
                let cell = self.collectionViewCellManager.defaultCellFor(collectionView: collectionView, indexPath: indexPath)
                cell.setCellWidth(width: cellWidth)
                return cell
        }
        
        cell.setCellWidth(width: cellWidth)
        
        guard let paramMap = self.createParameterMap(datapoint: datapoint, mapping: datapointClass.cellMapping) else {
            return cell
        }
        
        let onTap: (RSCollectionViewCell)->() = { [unowned self] cell in
            datapointClass.onTapActions.forEach({ (action) in
                self.processAction(action: action)
            })
        }
        
        cell.configure(paramMap: paramMap)
        cell.onTap = onTap
        
        if let cellTintJSON: JSON = datapointClass.cellTint,
            let state = self.state,
            let color: UIColor = RSValueManager.processValue(jsonObject: cellTintJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            cell.setCellTint(color: color)
        }
        
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tableViewDatapointIndices?.count ?? 0
    }
    
}
