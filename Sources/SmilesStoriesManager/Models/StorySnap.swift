//
//  StorySnap.swift
//
//  Created by Shmeel Ahmed on 31/10/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

public enum MediaType: String {
    case image
    case video
    case animation
    case unknown
}

public struct StorySnap: Codable {
    public var internalIdentifier: String? = ""
    // Store the deleted snaps id in NSUserDefaults, so that when app get relaunch deleted snaps will not display.
    public var isDeleted: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: internalIdentifier ?? "")
        }
        get{
            return UserDefaults.standard.value(forKey: internalIdentifier ?? "") != nil
        }
    }

    public var type: MediaType {
        switch mediaType {
        case MediaType.image.rawValue:
            return .image
        case MediaType.video.rawValue:
            return .video
        case MediaType.animation.rawValue:
            return .animation
        default:
            return .unknown
        }
    }

    public var title, storyDetailDescription: String?
    public var logoUrl: String?
    public var endDate: String?
    public var length: Int?
    public var mediaType: String?
    public var mediaUrl = ""
    public var redirectionUrl, uniqueIdentifier, location: String?
    public var isSharingAllowed, isFavoriteAllowed, isInfoAllowed, isFavorite, isbuttonEnabled: Bool?
    public var buttonTitle, infoUrl: String?
    public var restaurantInfoShareText:  String?
    public var restaurantRating: Double?
    public var promotionText: String?
    public var merchantLocations: [MerchantLocation]?
    public var points: String?
    public var cost: String?
    public var formattedEndDate:String? {
        if let date = stringToUTCDate(dateString: endDate) {
            let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: date)
            return String(format:"%02d days : %02d hrs : %02d mins",difference.day ?? 0, difference.hour ?? 0, difference.minute ?? 0)
        }
        return nil
    }
    var partnerName: String?
    var offerType: String?
    
    var isOfferStory:Bool{
        return (uniqueIdentifier ?? "").contains("OF_")
    }
    mutating func setFavourite(_ isFavorite:Bool){
        self.isFavorite = isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case storyDetailDescription = "description"
        case logoUrl
        case endDate, length, mediaType
        case mediaUrl
        case redirectionUrl
        case uniqueIdentifier, location, isSharingAllowed, isFavoriteAllowed, isInfoAllowed, isFavorite, isbuttonEnabled, buttonTitle, merchantLocations
        case infoUrl
        case restaurantInfoShareText
        case restaurantRating
        case points
        case cost
        case promotionText
        case partnerName
        case offerType
    }
    
    func stringToUTCDate(dateString: String?) -> Date? {
        
        guard let dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        if let date1 = dateFormatter.date(from: dateString) {
            return date1
        }
        return nil
        
    }
    
}

// MARK: - MerchantLocation
public struct MerchantLocation: Codable {
    public var locationName, locationAddress: String?
    public var locationLatitude, locationLongitude: Double?
    public var distance: Int?
    public var locationPhoneNumber: String?
}
