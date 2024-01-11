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
import SmilesSharedServices

public class StoriesViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    public enum Input {
        case getStories(categoryId:Int)
        case updateRestaurantWishlistStatus(operation: Int, restaurantId: String)
        case updateOfferWishlistStatus(operation: Int, offerId: String)
    }
    
    public enum Output {
        case fetchStoriesDidSucceed(response: Stories)
        case updateWishlistStatusDidSucceed(response: WishListResponseModel)
        case fetchDidFail(error: Error)
        case showHideLoader(shouldShow: Bool)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    public var stories: Stories?
    private var baseURL: String
    private var isGuestUser: Bool
    private let wishListViewModel = WishListViewModel()
    private var wishListUseCaseInput: PassthroughSubject<WishListViewModel.Input, Never> = .init()
    
    public init(baseURL: String, isGuestUser: Bool) {
        self.baseURL = baseURL
        self.isGuestUser = isGuestUser
    }
    
}

// MARK: - INPUT. View event methods
public extension StoriesViewModel {
    
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
            case .updateRestaurantWishlistStatus(operation: let operation, restaurantId: let restaurantId):
                self.bind(to: self.wishListViewModel)
                self.wishListUseCaseInput.send(.updateRestaurantWishlistStatus(operation: operation, restaurantId: restaurantId, baseUrl: self.baseURL))
            case .updateOfferWishlistStatus(operation: let operation, offerId: let offerId):
                self.bind(to: self.wishListViewModel)
                self.wishListUseCaseInput.send(.updateOfferWishlistStatus(operation: operation, offerId: offerId, baseUrl: self.baseURL))
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func bind(to wishListViewModel: WishListViewModel) {
        wishListUseCaseInput = PassthroughSubject<WishListViewModel.Input, Never>()
        let output = wishListViewModel.transform(input: wishListUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                self?.output.send(.showHideLoader(shouldShow: false))
                switch event {
                case .updateWishlistStatusDidSucceed(response: let response):
                    self?.output.send(.updateWishlistStatusDidSucceed(response: response))
                case .updateWishlistDidFail(error: let error):
                    debugPrint(error)
                    break
                }
            }.store(in: &cancellables)
    }

    
}
