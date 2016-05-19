//
//  NSData+String.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/18/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Foundation


extension NSData {
    
    var utf8String: String? {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
    }
}