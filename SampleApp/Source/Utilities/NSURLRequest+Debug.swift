//
//  NSURLRequest+Debug.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/18/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Foundation


extension NSURLRequest {
    override public var debugDescription: String {
        let url = self.URL
        let header = self.allHTTPHeaderFields
        
        var bodyString = ""
        if let body = self.HTTPBody {
            bodyString = (NSString(data: body, encoding: NSUTF8StringEncoding) ?? "") as String
        }
        
        return "Request: URL: \(url)\nHeader: \(header)\nBody: \(bodyString)"
    }
}