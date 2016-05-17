//
//  LogEntry+Extensions.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/12/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
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

extension LogEntry {
    
    public var level:LogLevel {
        get { return LogLevel(rawValue: self.levelRaw) ?? .Debug }
        set { self.levelRaw = newValue.rawValue }
    }
}