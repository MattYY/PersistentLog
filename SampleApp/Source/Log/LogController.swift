//
//  LogController.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/12/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import UIKit
import CoreData
import Logger

class LogController: UIViewController {
    private struct Constants {
        static let ErrorColor = UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        static let WarningColor = UIColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)
        static let InfoColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        static let DebugColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }
    
    private let filters: [String]
    private let tableView: UITableView = UITableView()
    private let filterButton: UIButton = UIButton()
    private let filterView: FilterView
    
    private var filterPickerTopConstraint: NSLayoutConstraint?
    private var resultsController: NSFetchedResultsController?
    private var isScrolledToTop: Bool {
        return tableView.contentOffset.y == -64
    }
    private var indexPathsToInsert: NSMutableSet = []

 
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
        let request = log.fetchRequestForLogEntry()
        request.fetchBatchSize = 20
        request.sortDescriptors = log.sortDescriptorsForLogEntry(timeAscending: false)
        
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: log.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        resultsController?.delegate = self
        updateResults()
    }
    
    private func updateResults() {
        guard let resultsController = resultsController else {
            return
        }
        
        resultsController.fetchRequest.predicate = log.predicateForLogEntry(filter, level: level)
        do {
            try resultsController.performFetch()
            self.tableView.reloadData()
        }
        catch let error as NSError {
            log.error("Unable to update results with error: \(error.localizedDescription)")
        }
    }
}


//MARK: - NSFetchedResultsControllerDelegate -
extension LogController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if isScrolledToTop {
            self.tableView.reloadData()
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier(
            MultiLineTextCell.Constants.ReuseIdentifier) as! MultiLineTextCell
        
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

    private func updateCell(cell: MultiLineTextCell, indexPath: NSIndexPath) {
        guard let resultsController = resultsController else {
            return
        }
        
        let entryOptional = resultsController.sections![indexPath.section].objects![indexPath.row] as? LogEntry
        guard let entry = entryOptional else {
            return
        }
        
        switch entry.level {
        case .Debug:
            cell.levelColor = Constants.DebugColor
            cell.customTextColor = .blackColor()
        case .Error:
            cell.levelColor = Constants.ErrorColor
            cell.customTextColor = .whiteColor()
        case .Info:
            cell.levelColor = Constants.InfoColor
            cell.customTextColor = .blackColor()
        case .Warn:
            cell.levelColor = Constants.WarningColor
            cell.customTextColor = .whiteColor()
        }
        
        cell.dateText = timeFormatter.stringFromDate(entry.timestamp)
        cell.messageOneText = entry.message
        cell.functionText = "Line: \(entry.line), Func: \(entry.function)"
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

        Cell.instance.dateText = timeFormatter.stringFromDate(entry.timestamp)
        Cell.instance.functionText = entry.function
        Cell.instance.messageOneText = entry.message
        
        return Cell.instance.calculateHeight()
    }
    
}


// MARK: - Actions -
extension LogController: UIActionSheetDelegate {
    
    func bindActions() {
        
        let share = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(showActionSheet));
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refreshData));
        navigationItem.setRightBarButtonItems([share, refresh], animated: false)
        
        filterButton.addTarget(self, action: #selector(toggleFilterPicker), forControlEvents: .TouchDown)
        
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

    func refreshData() {
        
        //only reload if there are items in the table
        guard let sections = resultsController?.sections
            where sections[0].numberOfObjects > 0 else {
            
            return
        }
        
        
        let top = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(top, atScrollPosition: .Top, animated: true)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    
    func clear() {
        //delete on a concurrent context
        let context = log.concurrentContext()
        log.deleteLogEntries(context) { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }        
    }
    
    func share() {
        if !USING_SIMULATOR {
            entriesAsString(500) {
                str -> () in
                
                let activityViewController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
                self.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    private func entriesAsString(limit: Int?, completion:(str: String) -> ()) {
        let context = log.concurrentContext()
        context.performBlock() { [weak self] () -> Void in

            let request = log.fetchRequestForLogEntry()
            if let limit = limit {
                request.fetchLimit = limit
            }

            let descriptors = log.sortDescriptorsForLogEntry(timeAscending: true)
            let predicate = log.predicateForLogEntry(self?.filter, level: self?.level)
            request.predicate = predicate
            request.sortDescriptors = descriptors
            
            let buffer = NSMutableString(string: "")
            do {
                let results = try context.executeFetchRequest(request) as? [LogEntry] ?? []
                for result in results {
                    let str = "++++++++++++++++++++++++++\n" +
                        "\(self!.timeFormatter.stringFromDate(result.timestamp) + ":")\n" +
                        "Line: \(result.line), Func: \(result.function)\n" +
                        "\(result.message)\n ++++++++++++++++++++++++++\n\n"
                    
                    buffer.appendString(str)
                }
            }
            catch _ as NSError {}
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(str: String(buffer))
            }
        }
    }
}





// MARK: - Layout -
extension LogController {
    
    private func layout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerClass(MultiLineTextCell.self, forCellReuseIdentifier: MultiLineTextCell.Constants.ReuseIdentifier)
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsZero
        tableView.separatorStyle = .None
        tableView.scrollsToTop = true
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .blackColor()
        filterButton.setTitleColor(.whiteColor(), forState: .Normal)
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
        if let constraint = filterPickerTopConstraint {
            
            let expanding:Bool
            if constraint.constant == 0 {
                constraint.constant = -200
                expanding = true
            }
            else {
                constraint.constant = 0
                expanding = false
            }
            
            filterButton.selected = expanding
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
