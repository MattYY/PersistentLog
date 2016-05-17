//
//  LogController.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/12/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import UIKit
import CoreData
import Log


class LogController: UIViewController {

    private let filters: [String]
    private let tableView: UITableView = UITableView()
    
    private var cellFirstMessageOpenStates = NSMutableSet()
    private var cellSecondMessageOpenStates = NSMutableSet()
    
    private let filterButton: UIButton = UIButton()
    private let filterView: FilterView
    
    private var filterPickerTopConstraint: NSLayoutConstraint?
    private var resultsController: NSFetchedResultsController?
    
    private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .LongStyle
        formatter.locale = .autoupdatingCurrentLocale()
        
        return formatter
    }()

    var filter: String? {
        didSet {
            updateResults()
        }
    }
    
    var level: LogLevel? {
        didSet {
            updateResults()
        }
    }
    
    
    //MARK: - View Controller Lifecycle
    required init(filters: [String] = []) {
        self.filters = filters
        
        filterView = FilterView(filters: filters)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bindActions()

        
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        filterView.delegate = self
        
        title = "Log"
        
        setupFetchedResultsController()
    }
    
    
    private func setupFetchedResultsController() {
        let context = log.mainContext
        let request = NSFetchRequest(entityName: Log.LogEntryEntityName)
        request.fetchBatchSize = 20
        request.sortDescriptors = sortDescriptors()
        
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        resultsController?.delegate = self
        updateResults()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if !isMovingFromParentViewController() {
            scrollToBottom(false, onlyIfAtBottom:false)
        }
    }
}





//MARK: - Data -
extension LogController {
    private func updateResults() {
        guard let resultsController = resultsController else {
            return
        }
        
        resultsController.fetchRequest.predicate = self.predicate(filter: self.filter, level: self.level)
        do {
            try resultsController.performFetch()
            
            //First Message is open by default
            for i in 0..<resultsController.sections![0].objects!.count {
                cellFirstMessageOpenStates.addObject(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.tableView.reloadData()
        }
        catch let error as NSError {
            log.error("Unable to update results with error: \(error.localizedDescription)")
        }
    }
    
    private func openMessageOneDrawer() {
        guard let resultsController = resultsController else {
            return
        }
        
        for i in 0..<resultsController.sections![0].objects!.count {
            cellFirstMessageOpenStates.addObject(NSIndexPath(forRow: i, inSection: 0))
        }
    }

    private func predicate(filter filter: String? = nil, level: LogLevel? = nil) -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let filter = filter {
            predicates.append(NSPredicate(format: "filter == %@", filter))
        }
        
        if let level = level {
            predicates.append(NSPredicate(format: "levelRaw >= %i", level.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func sortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "timestamp", ascending: true)]
    }
}



// MARK: - NSFetchedResultsControllerDelegate -
extension LogController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,
                                newIndexPath: NSIndexPath?) {
        
        let tableView = self.tableView
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                //only open 'firstMessage' on insert
                cellFirstMessageOpenStates.addObject(newIndexPath)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation:.Automatic)
            }
        case .Delete:
            if let indexPath = indexPath {
                cellFirstMessageOpenStates.removeObject(indexPath)
                cellSecondMessageOpenStates.removeObject(indexPath)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
            }
        case .Move:
            if let indexPath = indexPath, newIndexPath = newIndexPath {
                cellFirstMessageOpenStates.removeObject(indexPath)
                cellFirstMessageOpenStates.addObject(newIndexPath)
                cellSecondMessageOpenStates.removeObject(indexPath)
                cellSecondMessageOpenStates.addObject(newIndexPath)
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation:.Automatic)
            }
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MultiLineTextCell {
                    updateCell(cell, indexPath:indexPath)
                }
            }
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        scrollToBottom(true)
    }
}


// MARK: - FilterViewDelegate -
extension LogController: FilterViewDelegate {
    
    func filterViewDidUpdateLevel(level: LogLevel) {
        self.level = level
    }
    
    func filterViewDidUpdateFilter(filter: String?) {
        self.filter = filter
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource -
extension LogController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MultiLineTextCell.Constants.ReuseIdentifier) as! MultiLineTextCell
        updateCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForCellAtIndexPath(indexPath)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = resultsController?.sections {
            return sections[0].numberOfObjects
        }
        
        return 0
    }

    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        scrollToBottom(true, onlyIfAtBottom:false)
        return false
    }
    
    func scrollToBottom(animated: Bool, onlyIfAtBottom: Bool = true) {
        if tableView.tracking {
            return
        }
        
        if let sections = resultsController?.sections {
            let count = sections[0].numberOfObjects
            
            if count > 0 {
                let lastRow = NSIndexPath(forRow: count-1, inSection: 0)
                
                if onlyIfAtBottom {
                    var bottomPoint = tableView.contentOffset
                    bottomPoint.y += tableView.frame.height + tableView.rowHeight/2 - 10
                    
                    if let lastVisibleIndexPath = tableView.indexPathForRowAtPoint(bottomPoint) {
                        if lastVisibleIndexPath.row == lastRow.row {
                            self.tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: .Bottom, animated: animated)
                        }
                    }
                    else {
                        self.tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: .Bottom, animated: animated)
                    }
                }
                else {
                    self.tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: .Bottom, animated: animated)
                    
                }
            }
        }
    }
    
    private func updateCell(cell: MultiLineTextCell, indexPath: NSIndexPath) {
        guard let resultsController = resultsController else {
            return
        }

        
        let entryOptional = resultsController.sections![indexPath.section].objects![indexPath.row] as? LogEntry
        guard let entry = entryOptional else {
            return
        }
        
        if cellFirstMessageOpenStates.containsObject(indexPath) {
            cell.expandMessageOne = true
        }
        else {
            cell.expandMessageOne = false
        }
        
        if cellSecondMessageOpenStates.containsObject(indexPath) {
            cell.expandMessageTwo = true
        }
        else {
            cell.expandMessageTwo = false
        }
        
        switch entry.level {
        case .Debug:
            cell.backgroundColor = .whiteColor()
            cell.customTextColor = .darkGrayColor()
        case .Error:
            cell.backgroundColor = .redColor()
            cell.customTextColor = .whiteColor()
        case .Info:
            cell.backgroundColor = .whiteColor()
            cell.customTextColor = .blackColor()
        case .Warn:
            cell.backgroundColor = .orangeColor()
            cell.customTextColor = .whiteColor()
        }
        
        cell.delegate = self
        cell.dateText = timeFormatter.stringFromDate(entry.timestamp)
        cell.functionText = entry.function
    }
    
    
    private func heightForCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        guard let resultsController = resultsController else {
            return 0.0
        }
        
        struct Cell {
            static let instance = MultiLineTextCell()
        }
        
        let entryOptional = resultsController.sections![indexPath.section].objects![indexPath.row] as? LogEntry
        guard let entry = entryOptional else {
            return 0.0
        }
        
        var firstMessageIsOpen = false
        if cellFirstMessageOpenStates.containsObject(indexPath) {
            firstMessageIsOpen = true
        }
        
        var secondMessageIsOpen = false
        if cellSecondMessageOpenStates.containsObject(indexPath) {
            secondMessageIsOpen = true
        }
        
        Cell.instance.delegate = self
        Cell.instance.dateText = timeFormatter.stringFromDate(entry.timestamp)
        Cell.instance.functionText = entry.function
        
        return Cell.instance.calculateHeight(firstMessageIsOpen, messageTwoIsOpen: secondMessageIsOpen)
    }
    
}


// MARK: - MultiLineTextCellDelegate
extension LogController: MultiLineTextCellDelegate {
    
    func multiLineTextCell(cell: MultiLineTextCell, messageOneOpen: Bool, messageTwoOpen: Bool) {
        guard let indexPath = tableView.indexPathForCell(cell) else {
            return
        }
        
        if !messageOneOpen {
            cellFirstMessageOpenStates.removeObject(indexPath)
        }
        else {
            cellFirstMessageOpenStates.addObject(indexPath)
        }
        
        if !messageTwoOpen {
            cellSecondMessageOpenStates.removeObject(indexPath)
        }
        else {
            cellSecondMessageOpenStates.addObject(indexPath)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}


// MARK: - Actions
extension LogController: UIActionSheetDelegate {
    
    func bindActions() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action,
                                                            target: self,
                                                            action: #selector(LogController.showActionSheet));
        
        filterButton.addTarget(self, action: #selector(LogController.toggleFilterPicker as (LogController) -> () -> ()), forControlEvents: .TouchDown)
        
    }
    
    func showActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
            
        }
        alertController.addAction(cancelAction)
        
        let shareAction = UIAlertAction(title: "Share (Last 500)", style: .Default) {
            action in
            
            self.share()
        }
        alertController.addAction(shareAction)
        
        let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) {
            action in
            self.clear()
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func clear() {
        log.clear(log.concurrentContext()) { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }        
    }
    
    func share() {
        
        entriesAsString(500, completion: { (str) -> () in
            if let str = str {
                var items = [AnyObject]()
                items.append(str)
                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                self.presentViewController(activityViewController, animated: true, completion: nil)
            }
            
        })
        
    }
    
    func entriesAsString(limit: Int?, completion:(str: String?) -> ()) {

        let context = log.concurrentContext()
        context.performBlock({ [weak self] () -> Void in
            
            /*
            if let strongSelf = self {
                let request = log.entriesRequest(context, ascending: false)
                
                if let limit = limit {
                    request.fetchLimit = limit
                }
                
                let sort = NSSortDescriptor(key: "timestamp", ascending: false)
                request.sortDescriptors = [sort]
                
                let entity = NSEntityDescription.entityForName(LogStore.LogEntryEntityName, inManagedObjectContext: context)
                request.entity = entity
                
                var results: [AnyObject]? = nil
                do {
                    results = try context.executeFetchRequest(request)
                    
                    if let results = results as? [LogEntry] {
                        let buffer = NSMutableString()
                        for entry in Array(results.reverse()) {
                            buffer.appendString(entry.formattedTimestamp + ":")
                            buffer.appendString("\n")
                            buffer.appendString(entry.function)
                            buffer.appendString("\n")
                            buffer.appendString(entry.message)
                            buffer.appendString("\n\n")
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(str: String(buffer))
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(str:nil)
                        })
                    }
                }
                catch let error as NSError {
                    NSLog("Failed to get log entries: " + error.localizedDescription)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(str:nil)
                    })
                }
            }
            */
        })

    }
}





// MARK: - Layout
extension LogController {
    
    private func layout() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerClass(MultiLineTextCell.self, forCellReuseIdentifier: MultiLineTextCell.Constants.ReuseIdentifier)
        tableView.rowHeight = 120
        tableView.allowsSelection = false
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = UIColor.blackColor()
        filterButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        filterButton.setTitle("⇡  Filter  ⇡", forState: .Normal)
        filterButton.setTitle("⇣  Filter  ⇣", forState: .Selected)
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(filterButton)
        view.addSubview(filterView)
        
        let views = ["tableView":tableView, "filterButton":filterButton, "filterPicker":filterView]
        
        view.addConstraints( NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints( NSLayoutConstraint.constraintsWithVisualFormat("H:|[filterButton]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        
        view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: filterButton,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: filterView,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: filterButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: filterView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)
        )
        
        
        filterPickerTopConstraint = NSLayoutConstraint(
            item: filterView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        
        view.addConstraint(filterPickerTopConstraint!)
        
    }
    
    func toggleFilterPicker() {
        toggleFilterPicker(true)
    }
    
    private func toggleFilterPicker(animated:Bool = true) {
        if let constraint = filterPickerTopConstraint {
            
            let expanding:Bool
            if constraint.constant == 0 {
                constraint.constant = -200
                expanding = true
            } else {
                constraint.constant = 0
                expanding = false
            }
            filterButton.selected = expanding
            if (animated) {
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    if expanding {
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y+200)
                    }
                    else {
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y-200)
                    }
                    self.view.layoutIfNeeded()
                })
                
            }
        }
    }
    
}
