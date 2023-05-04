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

class StoriesViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getStories(categoryId:Int)
        case updateRestaurantWishlistStatus(operation: Int, restaurantId: String)
        case updateOfferWishlistStatus(operation: Int, offerId: String)
    }
    
    enum Output {
        case fetchStoriesDidSucceed(response: Stories)
        case updateWishlistStatusDidSucceed(response: StoriesWishListResponseModel)
        case fetchDidFail(error: Error)
        case showHideLoader(shouldShow: Bool)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var stories: Stories?
    private var baseURL: String
    private var isGuestUser: Bool
    
    init(baseURL: String, isGuestUser: Bool) {
        self.baseURL = baseURL
        self.isGuestUser = isGuestUser
    }
    
}

// MARK: - INPUT. View event methods
extension StoriesViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            guard let self else { return }
            self.output.send(.showHideLoader(shouldShow: true))
            switch event {
            case .getStories(let categoryId):
                SmilesStoriesHandler.shared.getStories(categoryId: categoryId, baseURL: self.baseURL, isGuestUser: self.isGuestUser) { stories in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.stories = stories
                    self.output.send(.fetchStoriesDidSucceed(response: stories))
                } failure: { error in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.output.send(.fetchDidFail(error: error))
                }
            case .updateRestaurantWishlistStatus(let operation, let restaurantId):
                SmilesStoriesHandler.shared.updateWishlistStatus(with: operation, restaurantId: restaurantId, offerId: nil, baseURL: self.baseURL) { response in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.output.send(.updateWishlistStatusDidSucceed(response: response))
                } failure: { error in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.output.send(.fetchDidFail(error: error))
                }
            case .updateOfferWishlistStatus(let operation, let offerId):
                SmilesStoriesHandler.shared.updateWishlistStatus(with: operation, restaurantId: nil, offerId: offerId, baseURL: self.baseURL) { response in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.output.send(.updateWishlistStatusDidSucceed(response: response))
                } failure: { error in
                    self.output.send(.showHideLoader(shouldShow: false))
                    self.output.send(.fetchDidFail(error: error))
                }

            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
}
