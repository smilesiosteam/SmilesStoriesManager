//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 13/03/2023.
//

import Foundation
import UIKit
import SmilesLanguageManager
import LottieAnimationManager
import SmilesFontsManager

class StoryPreviewFooterView: UIView {
    
    // MARK: - Details View
    private let detailsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "0c0011")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.fontTextStyle = .smilesTitle1
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    // MARK: - Cost View -
    private let costContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let smileyPointsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointsIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "smileyHearts")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.text = "2000 PTS"
        label.fontTextStyle = .smilesLabel2
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.fontTextStyle = .smilesLabel3
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "e9e9ec")
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "25 AED"
        label.fontTextStyle = .smilesLabel2
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let amountTrailingLabel: UILabel = {
        let label = UILabel()
        label.text = "onwards"
        label.fontTextStyle = .smilesLabel3
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "e9e9ec")
        return label
    }()
    
    // MARK: - Avail Now -
    private lazy var availNowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Avail now", for: .normal)
        button.fontTextStyle = .smilesTitle1
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(hex: "75428e")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(availPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Buttons Stack -
    private let buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "shareIcon"), for: .normal)
        button.setTitle("", for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var favouriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "fvrtIcon"), for: .normal)
        button.setTitle("", for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favouritePressed), for: .touchUpInside)
        return button
    }()
    
    private let favouriteAnimationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties -
    var primaryButtonAction = {}
    var infoButtonAction = {}
    var shareButtonAction = {}
    var favouriteButtonAction = {}
    private var bottomButtonHeight: CGFloat = 40
    var snapIndex = 0 {
        didSet{
            updateUI()
        }
    }
    var story:Story?
    
    // MARK: - Actions -
    @objc private func availPressed() {
        primaryButtonAction()
    }
    
    @objc private func sharePressed() {
        shareButtonAction()
    }
    
    @objc private func favouritePressed() {
        favouriteButtonAction()
    }
    
    // MARK: - Methods -
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func showFavouriteAnimation() {
        
        favouriteButton.setImage(nil, for: .normal)
        LottieAnimationManager.showAnimation(onView: favouriteButton, withJsonFileName: "Heart") { [weak self] isCompleted in
            self?.setFavouriteIcon()
        }
        
    }
    
    func setupUI(){
        
        backgroundColor = .clear
        addSubview(detailsView)
        addSubview(favouriteAnimationView)
        detailsView.addSubview(mainStackView)
        costContainerView.addSubview(smileyPointsStackView)
        
        smileyPointsStackView.addArrangedSubview(pointsIcon)
        smileyPointsStackView.addArrangedSubview(pointsLabel)
        smileyPointsStackView.addArrangedSubview(separatorLabel)
        smileyPointsStackView.addArrangedSubview(amountLabel)
        smileyPointsStackView.addArrangedSubview(amountTrailingLabel)
        
        detailsStackView.addArrangedSubview(titleLabel)
        detailsStackView.addArrangedSubview(costContainerView)
        
        buttonsStackView.addArrangedSubview(availNowButton)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(favouriteButton)
        
        mainStackView.addArrangedSubview(detailsStackView)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        detailsView.clipsToBounds = true
        detailsView.layer.cornerRadius = 16
        detailsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        availNowButton.clipsToBounds = true
        availNowButton.layer.cornerRadius = 24
        
        smileyPointsStackView.setCustomSpacing(8.0, after: pointsIcon)
        smileyPointsStackView.setCustomSpacing(12.0, after: pointsLabel)
        smileyPointsStackView.setCustomSpacing(12.0, after: separatorLabel)
        smileyPointsStackView.setCustomSpacing(4.0, after: amountLabel)
        
    }
    
    func updateUI(isFavouriteUpdated: Bool = false) {
        //refresh icon
        if let snap = story?.snaps?[snapIndex] {
            costContainerView.isHidden = !snap.isOfferStory
            if snap.isOfferStory {
                if let cost = snap.cost, let points=snap.points {
                    if cost != "0" && points != "0" {
                        pointsLabel.text = "\(points) " + SmilesLanguageManager.shared.getLocalizedString(for: "PTS")
                        amountLabel.text = "\(cost) " + SmilesLanguageManager.shared.getLocalizedString(for: "AED")
                        separatorLabel.text = SmilesLanguageManager.shared.getLocalizedString(for: "or")
                        amountTrailingLabel.text = SmilesLanguageManager.shared.getLocalizedString(for: "onwards")
                        
                        amountLabel.isHidden = false
                        separatorLabel.isHidden = false
                        amountTrailingLabel.isHidden = false
                        pointsIcon.isHidden = false
                    } else {
                        pointsLabel.text = SmilesLanguageManager.shared.getLocalizedString(for: "Free")
                        amountLabel.isHidden = true
                        separatorLabel.isHidden = true
                        amountTrailingLabel.isHidden = true
                        pointsIcon.isHidden = true
                    }
                } else {
                    costContainerView.isHidden = true
                }
            }else{
                
            }
            titleLabel.text = snap.storyDetailDescription
            shareButton.isHidden = !(snap.isSharingAllowed ?? false)
            favouriteButton.isHidden = !(snap.isFavoriteAllowed ?? false)
            self.availNowButton.isHidden = !(snap.isbuttonEnabled ?? (snap.redirectionUrl != nil))
            self.availNowButton.setTitle(snap.buttonTitle, for: .normal)
            if isFavouriteUpdated && (snap.isFavorite ?? false) {
                showFavouriteAnimation()
            } else {
                setFavouriteIcon()
            }
            
        }
    }
    
    private func setFavouriteIcon() {
        
        if let snap = story?.snaps?[snapIndex] {
            var image: UIImage?
            if snap.isFavorite ?? false {
                image = UIImage(named: "fvrtIconFilled")
            } else {
                image = UIImage(named: "fvrtIcon")
            }
            favouriteButton.setImage(image, for: .normal)
        }
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            detailsView.leadingAnchor.constraint(equalTo: self.igLeadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: self.igTrailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: self.igBottomAnchor),
            detailsView.topAnchor.constraint(equalTo: self.igTopAnchor)
        ])
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: detailsView.igLeadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: detailsView.igTrailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: detailsView.igBottomAnchor, constant: -8),
            mainStackView.topAnchor.constraint(equalTo: detailsView.igTopAnchor, constant: 18)
        ])
        
        NSLayoutConstraint.activate([
            favouriteAnimationView.leadingAnchor.constraint(equalTo: favouriteButton.igLeadingAnchor, constant: -23),
            favouriteAnimationView.trailingAnchor.constraint(equalTo: favouriteButton.igTrailingAnchor, constant: 23),
            favouriteAnimationView.topAnchor.constraint(equalTo: favouriteButton.topAnchor, constant: -23),
            favouriteAnimationView.bottomAnchor.constraint(equalTo: favouriteButton.igBottomAnchor, constant: 23)
        ])
        
        NSLayoutConstraint.activate([
            pointsIcon.heightAnchor.constraint(equalToConstant: 16),
            pointsIcon.widthAnchor.constraint(equalToConstant: 16),
            costContainerView.heightAnchor.constraint(equalToConstant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: bottomButtonHeight),
            shareButton.widthAnchor.constraint(equalToConstant: bottomButtonHeight),
            favouriteButton.heightAnchor.constraint(equalToConstant: bottomButtonHeight),
            favouriteButton.widthAnchor.constraint(equalToConstant: bottomButtonHeight),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 48),
            availNowButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
    }
    
}
