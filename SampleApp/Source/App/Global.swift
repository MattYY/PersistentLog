//
//  Global.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/16/16.
//

import Foundation
import PersistentLog


/// Logger
let log: PersistentLog = {
    let url = NSFileManager.defaultManager().URLsForDirectory(
        .ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
    url.URLByAppendingPathComponent("Log")
    
    return PersistentLog(directoryURL: url)
}()




var USING_SIMULATOR : Bool {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        return true
    #else
        return false
    #endif
}