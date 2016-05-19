//
//  LogEntry+Extensions.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/12/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import Foundation



extension LogEntry {
    
    public var level:LogLevel {
        get { return LogLevel(rawValue: self.levelRaw) ?? .Debug }
        set { self.levelRaw = newValue.rawValue }
    }
}