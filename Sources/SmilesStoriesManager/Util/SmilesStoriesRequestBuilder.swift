//
//  StoriesServiceEndPoints.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 28/10/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import NetworkingLayer

fileprivate typealias Headers = [String: String]
// if you wish you can have multiple services like this in a project
enum SmilesStoriesRequestBuilder {
    
    // organise all the end points here for clarity
    case getStories(request: StoriesRequestModel)

    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getStories:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    func createRequest(baseURL: String, endPoint: SmilesStoriesEndPoints) -> NetworkRequest {
        var headers: Headers = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(from: baseURL, for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .getStories(let request):
            return request
        }
    }
    
    // compose urls for each request
    func getURL(from baseURL: String, for endPoint: SmilesStoriesEndPoints) -> String {
        
        let endPoint = endPoint.serviceEndPoints
        switch self {
        case .getStories:
            return "\(baseURL)\(endPoint)"
        }
        
    }
}
