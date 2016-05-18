//
//  MockDataGenerator.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/18/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Foundation
import Log

class MockDataGenerator {
    static let Url = NSURL(string: "http://test.someurl.com")!
    static let request: NSMutableURLRequest = {
        let request = NSMutableURLRequest(URL: MockDataGenerator.Url)
        
        let bodyData = "id=CIW2yQEIo7bJAQjEtskBCP2VygEI7pzKAQ==&someParam=someValue"
        let headerData = [
            "Accept" : "application/json",
            "Accept-Language": "en-us",
            "Cache-Control": "max-age=0"
        ]
        
        request.allHTTPHeaderFields = headerData
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }()
    
    static let response: NSHTTPURLResponse = {
        return NSHTTPURLResponse(URL: MockDataGenerator.Url, statusCode: 404, HTTPVersion: nil, headerFields: ["Content-Type":"text/html"])!
    }()
    
    static let responseData: NSData = {
        let data = "first_name=Leonard&last_name=Nimoy&email=leonard@nimoy.com"
        return data.dataUsingEncoding(NSUTF8StringEncoding)!
    }()
    
    
    
    static func generate() {
        let log = Log.sharedInstance
        let queue1 = dispatch_queue_create("AppTestQueue", nil)
        //let queue2 = dispatch_queue_create("AppTestQueue", nil)
        var counter = 0
        
        
        dispatch_async(queue1) {
            while true {
                sleep(3)
                counter += 1
                log.network(request: request.debugDescription,
                            response: "Response: \(response.debugDescription)\nData: \(responseData.utf8String)")
            }
        }
    }
}