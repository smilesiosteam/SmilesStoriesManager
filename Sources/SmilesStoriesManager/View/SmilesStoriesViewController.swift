//
//  SmilesStoriesViewController.swift
//  
//
//  Created by Abdul Rehman Amjad on 13/03/2023.
//

import UIKit
import Combine
import SmilesLoader
import SmilesLanguageManager
import SmilesUtilities

public class SmilesStoriesViewController: IGStoryPreviewController, StoryboardInstantiable {
    
    // MARK: -- Variables
    private let input: PassthroughSubject<StoriesViewModel.Input, Never> = .init()
    private var viewModel: StoriesViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var favoriteOperation = 0 // Operation 1 = add and Operation 2 = remove
    private var baseURL: String = ""
    private var shareURL: String = ""
    public var favouriteUpdatedCallback: ((_ storyIndex:Int,_ snapIndex:Int,_ isFavourite:Bool) -> Void)? = nil
    public var isGuestUser: Bool = false
    
    // MARK: -- View LifeCycle
    public init?(favoriteOperation: Int = 0, baseURL: String, stories: [Story],handPickedStoryIndex: Int, handPickedSnapIndex: Int = 0, shareURL: String, isGuestUser: Bool) {
        super.init(stories: stories, handPickedStoryIndex: handPickedStoryIndex, handPickedSnapIndex: handPickedSnapIndex)
        self.favoriteOperation = favoriteOperation
        self.baseURL = baseURL
        self.shareURL = shareURL
        self.isGuestUser = isGuestUser
        viewModel = StoriesViewModel(baseURL: baseURL, isGuestUser: isGuestUser)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }
    
    // MARK: -- Binding
    
    func bind(to viewModel: StoriesViewModel) {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchStoriesDidSucceed:
                    break
                case .updateWishlistStatusDidSucceed(let response):
                    self?.resume()
                    self?.setFavourite(wishlistResponse: response, operation: self?.favoriteOperation ?? 0)
                case .fetchDidFail(let error):
                    self?.showAlertWithOkayOnly(
                        message: error.localizedDescription,
                        title: "Error")
                    { _ in
                        self?.dismiss()
                    }
                case .showHideLoader(let shouldShow):
                    guard let vu = self?.view else {return}
                    if shouldShow {
                        SmilesLoader.show(on: vu, isClearBackground: true)
                    } else {
                        SmilesLoader.dismiss(from: vu)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    override func favouriteUpdated(snapIndex: Int, storyIndex: Int) {
        if let snap = currentSelectedStory()?.snaps?[snapIndex],let _ = snap.uniqueIdentifier {
            self.favouriteUpdatedCallback?(storyIndex,snapIndex,snap.isFavorite ?? false)
        }
    }
    
    override func favouriteButtonPressed(snapIndex: Int, storyIndex: Int) {
        if !isGuestUser {
            if let snap = currentSelectedStory()?.snaps?[snapIndex] {
                if let id = snap.uniqueIdentifier {
                    favoriteOperation = (snap.isFavorite ?? false) ? 2 : 1
                    self.pause()
                    if !snap.isOfferStory {
                        input.send(.updateRestaurantWishlistStatus(operation: favoriteOperation, restaurantId: "\(id)"))
                    } else {
                        input.send(.updateOfferWishlistStatus(operation: favoriteOperation, offerId: "\(id)"))
                    }
                }
            }
        }
    }
    
    override func shareButtonPressed(snapIndex: Int, storyIndex: Int) {
        
        if let snap = stories[storyIndex].snaps?[snapIndex] {
            if !snap.isOfferStory {
                shareRestaurant(for: snap)
            } else {
                shareOffer(for: snap)
            }
        }
        
    }
    
}

extension SmilesStoriesViewController {
    func shareRestaurant(for snap: StorySnap) {
        var orderType: String = ""
        if let redirectionUrl = snap.redirectionUrl, redirectionUrl.contains("DELIVERY") {
            orderType = "DELIVERY"
        } else {
            orderType = "PICK_UP"
        }
        
        let sharingDialog = StoriesSharingText(
            restaurntId: snap.uniqueIdentifier ?? "",
            orderType: orderType,
            restaurantName: snap.title ?? "",
            restaurantInfoShareText: snap.restaurantInfoShareText ?? "",
            sourceView: view
        )
        
        let activityView = sharingDialog.shareLink()
        activityView.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.resume()
        }
        self.pause()
        present(activityView, animated: true)
    }
    
    func shareOffer(for snap: StorySnap) {
        
        let shareUrl = String(format: shareURL, snap.uniqueIdentifier ?? "", snap.offerType ?? "")
        
        let urlString = shareUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
        if let string = urlString, !string.isEmpty {
            let shareItems = [string]
            
            if shareItems.count > 0 {
                let activityViewController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)
                
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToWeibo,
                                                                UIActivity.ActivityType.print,
                                                                UIActivity.ActivityType.copyToPasteboard,
                                                                UIActivity.ActivityType.assignToContact,
                                                                UIActivity.ActivityType.saveToCameraRoll,
                                                                UIActivity.ActivityType.addToReadingList,
                                                                UIActivity.ActivityType.postToTencentWeibo,
                                                                UIActivity.ActivityType.airDrop]
                
                activityViewController.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    self.resume()
                }
                
                // present the view controller
                self.pause()
                present(activityViewController, animated: true)
            }
        }
    }
}
