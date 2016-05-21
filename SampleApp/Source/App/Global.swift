//
//  Global.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/16/16.
//

import Foundation
import Logger


/// Logger
let log: Logger = {
    let url = NSFileManager.defaultManager().URLsForDirectory(
        .ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
    url.URLByAppendingPathComponent("Log")
    
    return Logger(directoryURL: url)
}()




var USING_SIMULATOR : Bool {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        return true
    #else
        return false
    #endif
}