//
//  SmilesStories.swift
//  House
//
//  Created by Shmeel Ahmed on 31/10/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

// MARK: - SmilesStories
public struct Stories: Codable {
    var extTransactionID:String? = ""
    public var stories: [Story]?
    public mutating func setFavourite(isFavorite:Bool, storyIndex:Int, snapIndex:Int){
        stories?[storyIndex].setFavorite(isFavorite, index: snapIndex)
    }
    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case stories
    }
}

