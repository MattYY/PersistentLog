//
//  NSHTTPURLResponse+Data.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/18/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Foundation


extension NSHTTPURLResponse {
    
    override public var debugDescription: String {
        return "Status Code: \(self.statusCode)\n" +
               "Description: \(NSHTTPURLResponse.localizedStringForStatusCode(self.statusCode))"
    }
}