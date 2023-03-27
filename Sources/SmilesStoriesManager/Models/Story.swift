//
//  SmilesStory.swift
//
//  Created by Shmeel Ahmed on 31/10/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
// MARK: - SmilesStory
public struct Story: Codable, Equatable {
    public var lastPlayedSnapIndex:Int? = 0
    public var isCompletelyVisible:Bool? = false
    public var isCancelledAbruptly:Bool? = false
    public var storyID: String?
    public var title: String? = nil
    public var storyDescription: String? = nil
    public var logoUrl: String? = nil
    public var imageUrl: String? = nil
    public var snaps: [StorySnap]? = []
    
    mutating func setFavorite(_ isFavorite:Bool,index:Int){
        self.snaps?[index].setFavourite(isFavorite)
    }
    
    public static func == (lhs: Story, rhs: Story) -> Bool {
        return lhs.storyID == rhs.storyID
    }
    
    enum CodingKeys: String, CodingKey {
        case storyID = "id"
        case title
        case storyDescription = "description"
        case logoUrl
        case imageUrl
        case snaps = "storyDetails"
    }
}
