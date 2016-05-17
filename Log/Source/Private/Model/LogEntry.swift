//
//  LogEntry.swift
//  
//
//  Created by Josh Rooke-Ley on 5/4/15.
//
//

import Foundation
import CoreData


public class LogEntry: NSManagedObject {

    @NSManaged var levelRaw: Int16

    @NSManaged public var file: String
    @NSManaged public var function: String
    @NSManaged public var line: Int32
    @NSManaged public var message: String
    @NSManaged public var timestamp: NSDate
    @NSManaged public var filter: String?

    override public var description : String {
        return "\(function):\(line) \(message)"
    }
    
}
