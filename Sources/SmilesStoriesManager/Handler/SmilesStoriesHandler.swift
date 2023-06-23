//
//  StoriesViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/2/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import UIKit

open class SmilesStoriesHandler {
    
    public static let shared = SmilesStoriesHandler()
    
    private var cancellables = Set<AnyCancellable>()
    
    public func getStories(categoryId: Int, baseURL: String, isGuestUser: Bool, success: @escaping (Stories) -> Void, failure: @escaping (NetworkError) -> Void) {
        let storiesRequest = StoriesRequestModel(
            categoryId: categoryId, isGuestUser: isGuestUser
        )
        
        let service = SmilesGetStoriesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .storiesList
        )
        
        service.getStories(request: storiesRequest)
            .sink { completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    failure(error)
                default: break
                }
            } receiveValue: { response in
                success(response)
            }
            .store(in: &cancellables)
    }
    
    public func updateWishlistStatus(with operation: Int, restaurantId: String?, offerId: String?, baseURL: String, success: @escaping (StoriesWishListResponseModel) -> Void, failure: @escaping (NetworkError) -> Void) {

        let updateWishListRequest = StoriesWishListRequestModel(
            restaurantId: restaurantId,
            operation: operation,
            offerId: offerId
        )
        
        let service = SmilesGetStoriesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .updateWishlist
        )
        
        service.updateWishList(request: updateWishListRequest)
            .sink { completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    failure(error)
                default:
                    break
                }
            } receiveValue: { response in
                success(response)
            }
        .store(in: &cancellables)
    }
    
}
