//
//  Global.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/16/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Log


/// Singleton
let log = Log()


var USING_SIMULATOR : Bool {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        return true
    #else
        return false
    #endif
}