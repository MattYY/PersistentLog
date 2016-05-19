//
//  LogStore.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/12/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import Foundation
import CoreData



///
public class Log {
    private static let DirectoryURLName = "Log"
    private static let LogModelName = "LogModel"
    private static let BundleId = "com.sonic.sonicdrivein.Log"
    private static let LogEntryEntityName = "LogEntry"
    
    private var minLogLevel: LogLevel = .Debug
    private var excludedFilters: [String] = []

    
    ///
    public var echoToConsole: Bool = false
    
    ///
    public var persistToStore: Bool = false
    
    //
    private lazy var stack : CoreDataStack = {
        let bundle = NSBundle(identifier: Log.BundleId)!
        let url = NSFileManager.defaultManager().URLsForDirectory(
            .ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
        
        url.URLByAppendingPathComponent(Log.DirectoryURLName)
        
        var error: NSError?
        if !url.checkResourceIsReachableAndReturnError(&error) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(
                url, withIntermediateDirectories: true, attributes: nil)
        }

        return try! CoreDataStack(bundle: bundle, directoryURL: url, modelName: Log.LogModelName)
    }()

    //Hide the initializer to inforce the Singleton
    public init() {}
}



/// Logging accessors
extension Log {
    
    ///
    public func debug(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Debug, filter: filter, file:file, function:function, line:line)
    }
    
    ///
    public func info(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Info, filter: filter, file:file, function:function, line:line)
    }
    
    ///
    public func warn(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Warn, filter: filter, file:file, function:function, line:line)
    }

    ///
    public func error(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Error, filter: filter, file:file, function:function, line:line)
    }

    
    private func addEntry(msg: String, level:LogLevel, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        
        if let filter = filter where self.excludedFilters.contains(filter) {
            return
        }
        
        if level.rawValue < self.minLogLevel.rawValue {
            return
        }
        
        if self.echoToConsole {
            let string = String(
                "+\n" +
                "File: \(file)\n" +
                "Function: \(function), Line: \(line)\n" +
                "--------------------------------------\n" +
                 msg + "\n" +
                "+"
            )
            print(string)
        }
        
        if self.persistToStore {
            let context = stack.concurrentContext()
            context.performBlock() {
                let entry = NSEntityDescription.insertNewObjectForEntityForName(
                    Log.LogEntryEntityName, inManagedObjectContext: context) as! LogEntry
                
                entry.level = level
                entry.filter = filter
                entry.timestamp = NSDate()
                entry.message = msg
                entry.file = file
                entry.line = line
                entry.function = function
                
                self.stack.saveToDisk(context)
            }
        }
    }
}




/// Storage accessors
extension Log {

    ///
    public var mainContext: NSManagedObjectContext {
        return stack.mainContext
    }
    
    ///
    public func concurrentContext() -> NSManagedObjectContext {
        return stack.concurrentContext()
    }
    
    ///
    public func setExcludedFilters(filters: [String]) {
        stack.mainContext.performBlock {
            self.excludedFilters = filters
        }
    }    
    
    ///
    public func setMinimumLogLevel(level: LogLevel) {
        stack.mainContext.performBlock {
            self.minLogLevel = level
        }
    }
    
    ///
    public func fetchRequestForLogEntry() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: Log.LogEntryEntityName)
        request.fetchBatchSize = 20
        return request
    }

    ///
    public func predicateForLogEntry(filter: String? = nil, level: LogLevel? = nil, startDate: NSDate? = nil, endDate: NSDate? = nil) -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let filter = filter {
            predicates.append(NSPredicate(format: "filter == %@", filter))
        }
        
        if let level = level {
            predicates.append(NSPredicate(format: "levelRaw >= %i", level.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    ///
    public func sortDescriptorsForLogEntry(timeAscending ascending: Bool) -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "timestamp", ascending: ascending)]
    }
    
    ///
    public func deleteLogEntries(filter: String? = nil, level: LogLevel? = nil, completion: ((error: ErrorType?) -> Void)? = nil) {
        
        let context = stack.concurrentContext()
        context.performBlock {
            let request = self.fetchRequestForLogEntry()
            request.predicate = self.predicateForLogEntry(filter, level: level)
            
            do {
                let results = try context.executeFetchRequest(request) as? [LogEntry] ?? []
                for result in results {
                    context.deleteObject(result)
                }
                
                self.stack.saveToDisk(context, completion: completion)
            }
            catch let error as NSError {
                completion?(error: error)
                self.error("Failed to get log entries: " + error.localizedDescription)
            }
        }
    }
}

