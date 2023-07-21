//
//  StoriesServiceUseCase.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 28/10/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol SmilesStoriesServiceable {
    func getStories(request: StoriesRequestModel) -> AnyPublisher<Stories, NetworkError>
}

// getstoriesrepository
class SmilesGetStoriesRepository: SmilesStoriesServiceable {
    
    private var networkRequest: Requestable
    private var baseURL: String
    private var endPoint: SmilesStoriesEndPoints

  // inject this for testability
    init(networkRequest: Requestable, baseURL: String, endPoint: SmilesStoriesEndPoints) {
        self.networkRequest = networkRequest
        self.baseURL = baseURL
        self.endPoint = endPoint
    }
    
    func getStories(request: StoriesRequestModel) -> AnyPublisher<Stories, NetworkError> {
        let endPoint = SmilesStoriesRequestBuilder.getStories(request: request)
        let request = endPoint.createRequest(
            baseURL: baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
