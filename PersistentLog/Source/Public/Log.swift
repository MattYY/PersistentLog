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
public class PersistentLog {
    private static let DirectoryURLName = "Log"
    private static let LogModelName = "LogModel"
    private static let BundleId = "com.PersistentLog"
    private static let LogEntryEntityName = "LogEntry"
    
    private var minLogLevel: LogLevel = .Debug
    private var excludedFilters: [String] = []
    
    //
    private let stack : CoreDataStack
    
    /// Turn on/off logging to the console
    public var echoToConsole: Bool = false
    
    /// Turn on/off logging to the persistent store
    public var persistToStore: Bool = false
    
    
    /// Use this initializer if you want to utilize the persistent storage capabilities.
    ///
    /// - parameter directoryURL: URL at which you would like to store the underlying database files.
    ///
    public init(directoryURL: NSURL) {
         let bundle = NSBundle(identifier: PersistentLog.BundleId)!
        stack = try! CoreDataStack(bundle: bundle, directoryURL: directoryURL, modelName: PersistentLog.LogModelName)
    }
}



/// Logging accessors
extension PersistentLog {
    
    /// Interface for logging `debug` level messages
    ///
    /// parameter msg - the message which to log
    ///
    /// parameter filter - A string that can be used to sort/fetch stored log entries
    ///
    /// parameter file - A value representing the file name that generated the log message.
    ///                  Always use the default value.
    ///
    /// parameter function - A value representing the function name that called the log
    ///                      function.  Always use the default value.
    ///
    /// parameter line - A value representing the line number of the function in the file in
    ///                  which the log message was generated.  Always use the default value.
    ///
    public func debug(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Debug, filter: filter, file:file, function:function, line:line)
    }
    
    /// Interface for logging `info` level messages
    ///
    /// parameter msg - the message which to log
    ///
    /// parameter filter - A string that can be used to sort/fetch stored log entries
    ///
    /// parameter file - A value representing the file name that generated the log message.
    ///                  Always use the default value.
    ///
    /// parameter function - A value representing the function name that called the log
    ///                      function.  Always use the default value.
    ///
    /// parameter line - A value representing the line number of the function in the file in
    ///                  which the log message was generated.  Always use the default value.
    ///
    public func info(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Info, filter: filter, file:file, function:function, line:line)
    }
    
    /// Interface for logging `warn` level messages
    ///
    /// parameter msg - the message which to log
    ///
    /// parameter filter - A string that can be used to sort/fetch stored log entries
    ///
    /// parameter file - A value representing the file name that generated the log message.
    ///                  Always use the default value.
    ///
    /// parameter function - A value representing the function name that called the log
    ///                      function.  Always use the default value.
    ///
    /// parameter line - A value representing the line number of the function in the file in
    ///                  which the log message was generated.  Always use the default value.
    ///
    public func warn(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Warn, filter: filter, file:file, function:function, line:line)
    }

    /// Interface for logging `error` level messages
    ///
    /// parameter msg - the message which to log
    ///
    /// parameter filter - A string that can be used to sort/fetch stored log entries
    ///
    /// parameter file - A value representing the file name that generated the log message.
    ///                  Always use the default value.
    ///
    /// parameter function - A value representing the function name that called the log
    ///                      function.  Always use the default value.
    ///
    /// parameter line - A value representing the line number of the function in the file in
    ///                  which the log message was generated.  Always use the default value.
    ///
    public func error(msg: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(msg, level: .Error, filter: filter, file:file, function:function, line:line)
    }

    
    private func addEntry(msg: String, level:LogLevel, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        
        if let filter = filter where self.excludedFilters.contains(filter) {
            return
        }
        
        if level.rawValue <= self.minLogLevel.rawValue {
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
                    PersistentLog.LogEntryEntityName, inManagedObjectContext: context) as! LogEntry
                
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
extension PersistentLog {

    /// The underlying Core Data context that operates on the main queue.
    public var mainContext: NSManagedObjectContext {
        return stack.mainContext
    }
    
    /// A disposable, concurrent, Core Data context.
    public func concurrentContext() -> NSManagedObjectContext {
        return stack.concurrentContext()
    }
    
    /// Excluded filters will not be persistented or logged to console.
    public func setExcludedFilters(filters: [String]) {
        stack.mainContext.performBlock {
            self.excludedFilters = filters
        }
    }    
    
    /// Levels below the min log level will not be persisted or logged to console.
    public func setMinimumLogLevel(level: LogLevel) {
        stack.mainContext.performBlock {
            self.minLogLevel = level
        }
    }
    
    /// Returns a `NSFetchRequest` object that can be used to query for `LogEntry` items.
    public func fetchRequestForLogEntry() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: PersistentLog.LogEntryEntityName)
        request.fetchBatchSize = 20
        return request
    }

    /// Creates a `NSPredicate` object that can be used to adjust a `LogEntry` fetch.
    ///
    /// parameter filter - A string by which to filter fetched `LogEntry` items.
    ///
    /// parameter level - A `LogLevel` by which to filter fetched `LogEntry` items.
    ///
    /// returns: An `NSPredicate`
    ///
    public func predicateForLogEntry(filter: String? = nil, level: LogLevel? = nil) -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let filter = filter {
            predicates.append(NSPredicate(format: "filter == %@", filter))
        }
        
        if let level = level {
            predicates.append(NSPredicate(format: "levelRaw >= %i", level.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    /// Creates an array of `NSSortDescriptor` objects that can be used to adjust a `LogEntry` fetch.
    ///
    /// parameter ascending - A Bool that can be used to specify whether to return values in
    ///                       time-ascending or time-descending order.
    ///
    /// returns: An array of `NSSortDescriptor`s
    ///
    public func sortDescriptorsForLogEntry(timeAscending ascending: Bool) -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "timestamp", ascending: ascending)]
    }
    
    /// Delete `LogEntry`s at the specified filter and level. If no filter and level values are
    /// specified all entries will be deleted.
    ///
    /// parameter filter - Limits the deletion to only objects with the specified filter value.
    ///
    /// parameter level - Limits the deletion to only objects with the specified level value.
    ///
    /// parameter completion - An optional completion handler that returns an error if one
    ///                        is encountered during deletion.
    ///
    public func deleteLogEntries(
        context: NSManagedObjectContext? = nil, filter: String? = nil,
        level: LogLevel? = nil, completion: ((error: ErrorType?) -> Void)? = nil) {
        
        let context = context == nil ? stack.mainContext : context
        context?.performBlock {
            let request = self.fetchRequestForLogEntry()
            request.predicate = self.predicateForLogEntry(filter, level: level)
            
            do {
                let results = try context?.executeFetchRequest(request) as? [LogEntry] ?? []
                for result in results {
                    context?.deleteObject(result)
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

