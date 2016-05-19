//
//  LogLevel.swift
//  Log
//
//  Created by Matthew Yannascoli on 5/18/16.
//  Copyright © 2016 America's Drive-In Brand Properties LLC. All rights reserved.
//

import Foundation


public enum LogLevel: Int16 {
    case Debug = 0
    case Info = 1
    case Warn = 2
    case Error = 3
    
    public func all() -> [LogLevel] {
        return [Debug, Info, Warn, Error]
    }
}