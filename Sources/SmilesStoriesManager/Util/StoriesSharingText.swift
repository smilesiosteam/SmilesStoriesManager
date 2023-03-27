//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 24/03/2023.
//

import Foundation
import UIKit

protocol SharingDialogue{
    var restaurantId: String {get}
    var orderType : String {get}
    var restaurantName : String {get}
    var restaurantInfoShareText : String? {get}
    
    func shareLink() -> UIActivityViewController
}

class StoriesSharingText: SharingDialogue{
    
    var restaurantId: String
    var orderType: String
    var restaurantName: String
    var restaurantInfoShareText: String?
    var sourceView: UIView?
    
    
    init(restaurntId : String, orderType : String, restaurantName :String, restaurantInfoShareText:String?, sourceView: UIView? ) {
        self.restaurantId = restaurntId
        self.orderType = orderType
        self.restaurantName = restaurantName
        self.restaurantInfoShareText = restaurantInfoShareText
        self.sourceView = sourceView
    }
    
    func shareLink() -> UIActivityViewController {
        // Old restaurant deeplink
// "https://smilesmobile.page.link/?link=https://smiles/restaurant/\(self.restaurantId)/\(self.orderType)&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp"
        
        // New restaurant deeplink according to Reem
        let shareLink = "https://smilesmobile.page.link/?link=https://smilesmobile.page.link/restaurant/\(self.restaurantId)/\(self.orderType)&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp"
        if let shareText = self.restaurantInfoShareText, !shareText.isEmpty {
            let dummyText = shareText.replacingOccurrences(of: "$Restaurant_Name$", with: self.restaurantName)
            let link = dummyText.replacingOccurrences(of: "$DeepLink_Restaurant$", with: shareLink)
            return self.shareText(link: link,sourceView: self.sourceView)
        } else {
            return self.shareText(link: shareLink,sourceView:self.sourceView)
        }
    }
    
    func shareText(link: String, sourceView:UIView?) -> UIActivityViewController{
        let textShare = [ link ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToWeibo,
                                                        UIActivity.ActivityType.print,
                                                        /*UIActivity.ActivityType.copyToPasteboard,*/
                                                        UIActivity.ActivityType.assignToContact,
                                                        UIActivity.ActivityType.saveToCameraRoll,
                                                        UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.postToTencentWeibo,
                                                        UIActivity.ActivityType.airDrop]
        return activityViewController
    }
    
}
