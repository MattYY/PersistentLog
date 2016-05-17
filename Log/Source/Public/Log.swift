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
    static let DirectoryURLName = "Log"
    static let LogModelName = "LogModel"
    static let BundleId = "com.sonic.sonicdrivein.Log"
    
    private(set) var minLogLevel: LogLevel = .Debug
    private(set) var excludedFilters: [String] = []
    
    
    ///
    public static let LogEntryEntityName = "LogEntry"
    
    ///
    public var echoToConsole: Bool = false
    
    ///
    public var persistToStore: Bool = false
    
    /// I am a Singleton!
    public static let sharedInstance = Log()
    
    
    //
    private lazy var store : CoreDataStack = {
        let bundle = NSBundle(identifier: Log.BundleId)!
        let url = NSFileManager.defaultManager().URLsForDirectory(
            .ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
        
        url.URLByAppendingPathComponent(Log.DirectoryURLName)
        
        var error: NSError?
        if !url.checkResourceIsReachableAndReturnError(&error) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(
                url, withIntermediateDirectories: true, attributes: nil)
        }
        
        print(url)
        return try! CoreDataStack(bundle: bundle, directoryURL: url, modelName: Log.LogModelName)
    }()

    //Hide the initializer to inforce the Singleton
    private init() {}
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
    
    ///
    public func network(request: String, response: String, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        addEntry(request, msg2: response, level: .Error, filter: filter, file:file, function:function, line:line)
    }
    
    
    private func addEntry(msg: String, msg2: String? = nil, level:LogLevel, filter: String? = nil, file: String = #file, function: String = #function, line: Int32 = #line) {
        
        if let filter = filter where self.excludedFilters.contains(filter) {
            return
        }
        
        if level.rawValue < self.minLogLevel.rawValue {
            return
        }
        
        if self.echoToConsole {
            let string = String(
                "\n" +
                "File: \(file)\n" +
                "Function: \(function), Line: \(line)\n" +
                 msg + "\n" +
                "\n"
            )
            
            print(string)
        }
        
        if self.persistToStore {
            let context = self.store.concurrentContext()
            context.performBlock() {
                let entry = NSEntityDescription.insertNewObjectForEntityForName(
                    Log.LogEntryEntityName, inManagedObjectContext: context) as! LogEntry
                
                entry.level = level
                entry.filter = filter
                entry.timestamp = NSDate()
                entry.message = msg
                entry.message2 = msg2
                entry.file = file
                entry.line = line
                entry.function = function
                
                self.store.saveToDisk(context)
            }
        }
    }
}




/// Storage accessors
extension Log {
    
    ///
    public var mainContext: NSManagedObjectContext {
        return store.mainContext
    }
    
    ///
    public func concurrentContext() -> NSManagedObjectContext {
        return store.concurrentContext()
    }
    
    ///
    public func setExcludedFilters(filters: [String]) {
        store.mainContext.performBlock {
            self.excludedFilters = filters
        }
    }    
    
    ///
    public func setMinimumLogLevel(level: LogLevel) {
        store.mainContext.performBlock {
            self.minLogLevel = level
        }
    }
    
    
    ///
    public func clear(context: NSManagedObjectContext, filter: String? = nil, level: LogLevel? = nil,
        completion: ((error: ErrorType?) -> Void)? = nil) {
        
        context.performBlock {
            self.fetchEntries(context, filter: filter, level: level) {
                entries in
                
                for entry in entries {
                    context.deleteObject(entry)
                }
            }
            
            self.store.saveToDisk(context, completion: completion)
        }
    }
}




//MARK - Private -
extension Log {    
    private func fetchEntries(
        context: NSManagedObjectContext, filter: String? = nil, level: LogLevel? = nil, completion: (entries: [LogEntry]) -> Void) {
        
        context.performBlock {
            let request = NSFetchRequest(entityName: Log.LogEntryEntityName)
            request.predicate = self.predicate(filter, level: level)
            
            do {
                let results = try context.executeFetchRequest(request) as? [LogEntry] ?? []
                completion(entries: results)
            }
            catch let error as NSError {
                self.error("Failed to get log entries: " + error.localizedDescription)
            }
        }
    }
    
    
    private func predicate(filter:String? = nil, level:LogLevel? = nil) -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let filter = filter {
            predicates.append(NSPredicate(format: "filter == %@", filter))
        }
        
        if let level = level {
            predicates.append(NSPredicate(format: "levelRaw >= %i", level.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}


