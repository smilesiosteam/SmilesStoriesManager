//
//  StoriesWishListResponseModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/2/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

public struct StoriesWishListResponseModel : Codable {
    
    public let extTransactionId: String?
    public let updateWishlistStatus : Bool?
    public let responseMessage : String?
    public let responseCode: String?
    
}
