//
//  StoriesRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 28/10/2022.
//  Copyright (c) 2022 All rights reserved.
//


import Foundation
import SmilesBaseMainRequestManager

// Inherit SmilesBaseMainRequest instead of Codable in case you have some base class.
class StoriesRequestModel: SmilesBaseMainRequest {

    // MARK: - Model Variables
    var categoryId: Int?
    var isGuestUser: Bool?
    var themeId: Int?
    init(categoryId: Int?, isGuestUser: Bool? ,themeId: Int? = nil) {
        super.init()
        self.categoryId = categoryId
        self.isGuestUser = isGuestUser
        self.themeId = themeId
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    enum CodingKeys: CodingKey {
        case categoryId
        case isGuestUser
        case themeId
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.categoryId, forKey: .categoryId)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
        try container.encodeIfPresent(self.themeId, forKey: .themeId)
    }
    
    
    
}
