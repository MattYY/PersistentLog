//
//  PrettyNetworkLogMessage.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/19/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import Foundation


class PrettyLog {
    
    static func network(
        request: NSURLRequest? = nil, response: NSHTTPURLResponse? = nil, data: NSData? = nil) -> String {
        
        //Request
        var requestString = ""
        if let request = request {
            let url = request.URL
            let header = request.allHTTPHeaderFields
            
            var bodyString = ""
            if let body = request.HTTPBody {
                bodyString = (NSString(data: body, encoding: NSUTF8StringEncoding) ?? "") as String
            }
            requestString = "URL: \(url)\nHeader: \(header)\nBody: \(bodyString)"
        }
        
        //Response
        var responseString = ""
        if let response = response {
            responseString = "Status Code: \(response.statusCode)\n" +
                             "Description: \(NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode))"
        }
        
        //Data
        var dataString = ""
        if let data = data {
            dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
        }
        
        let compositeString = "Request:\n" +
        "-----------------------------------\n" +
        "\(requestString)\n" +
        "\n" +
        "Response:\n" +
        "-----------------------------------\n" +
        "\(responseString)\n" +
        "\n" +
        "Data:\n" +
        "-----------------------------------\n" +
        "\(dataString)"
        
        return compositeString
    }
}