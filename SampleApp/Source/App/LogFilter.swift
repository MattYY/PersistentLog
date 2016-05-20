//
//  App.swift
//  SampleApp
//
//  Created by Josh Rooke-Ley on 5/8/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//



enum LogFilter: String {
    case Apple = "Apple"
    case Orange = "Orange"
    case Bannana = "Bannana"
    case Kiwi = "Kiwi"
    case Network = "Network"
    
    static func all() -> [LogFilter] {
        return [
            Apple,
            Orange,
            Bannana,
            Kiwi,
            Network]
    }
    
    static func values() -> [String] {
        return all().map {
            (filter) -> String in
            return filter.rawValue
        }
    }
}