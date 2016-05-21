//
//  MockDataGenerator.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/18/16.
//

import Foundation

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
        let queue1 = dispatch_queue_create("AppTestQueue", nil)
        dispatch_async(queue1) {
            var counter = 0
            while true {
                sleep(arc4random_uniform(20) + 2)
                counter += 1                
                log.warn(PrettyLog.network(request, response: response, data: responseData), filter: LogFilter.Network.rawValue)
            }
        }
        
        let queue2 = dispatch_queue_create("AppTestQueue", nil)
        dispatch_async(queue2) {
            var counter = 0
            while true {
                sleep(arc4random_uniform(20) + 2)
                counter += 1
                log.error("Banana Error", filter: LogFilter.Bannana.rawValue)
            }
        }
        
        let queue3 = dispatch_queue_create("AppTestQueue", nil)
        dispatch_async(queue3) {
            var counter = 0
            while true {
                sleep(arc4random_uniform(20) + 2)
                counter += 1
                log.info("Random Info Random Info Random Info Random Info Random Info Random Info Random Info", filter: LogFilter.Apple.rawValue)
            }
        }
        
        let queue4 = dispatch_queue_create("AppTestQueue", nil)
        dispatch_async(queue4) {
            var counter = 0
            while true {
                sleep(arc4random_uniform(20) + 2)
                counter += 1
                log.debug("Random Info Random Info Random Info Random Info Random Info Random Info Random Info", filter: LogFilter.Apple.rawValue)
            }
        }
    }
}