//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 13/03/2023.
//

import Foundation
import UIKit
import SmilesLanguageManager
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
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = SmilesFonts.circular(.bold).getFont(size: 22)
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
        view.spacing = 4
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointsIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "SmilesSmiley")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.text = "2000 PTS"
        label.font = SmilesFonts.circular(.medium).getFont(size: 16)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.font = SmilesFonts.circular(.regular).getFont(size: 12)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "cecccf")
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "25 AED"
        label.font = SmilesFonts.circular(.medium).getFont(size: 16)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let amountTrailingLabel: UILabel = {
        let label = UILabel()
        label.text = "onwards"
        label.font = SmilesFonts.circular(.regular).getFont(size: 12)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "cecccf")
        return label
    }()
    
    
    // MARK: - Description -
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Promotion"
        label.font = SmilesFonts.circular(.regular).getFont(size: 12)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "cecccf")
        return label
    }()
    
    // MARK: - Avail Now -
    private lazy var availNowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Avail Now", for: .normal)
        button.titleLabel?.font = SmilesFonts.circular(.medium).getFont(size: 16)
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
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "info_icon"), for: .normal)
        button.setTitle("", for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(infoPressed), for: .touchUpInside)
        return button
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
    
    // MARK: - Rating View -
    private let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "131728", alpha: 0.72)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "rating-icon")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.text = "4.9"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    // MARK: - Properties -
    var primaryButtonAction = {}
    var infoButtonAction = {}
    var shareButtonAction = {}
    var favouriteButtonAction = {}
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
    
    @objc private func infoPressed() {
        infoButtonAction()
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
    
    func setupUI(){
        
        backgroundColor = .clear
        addSubview(detailsView)
        addSubview(ratingView)
        detailsView.addSubview(mainStackView)
        ratingView.addSubview(ratingIcon)
        ratingView.addSubview(tagLabel)
        costContainerView.addSubview(smileyPointsStackView)
        
        smileyPointsStackView.addArrangedSubview(pointsIcon)
        smileyPointsStackView.addArrangedSubview(pointsLabel)
        smileyPointsStackView.addArrangedSubview(separatorLabel)
        smileyPointsStackView.addArrangedSubview(amountLabel)
        smileyPointsStackView.addArrangedSubview(amountTrailingLabel)
        
//        detailsStackView.backgroundColor = .red
//        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        costContainerView.backgroundColor = .blue
        detailsStackView.addArrangedSubview(titleLabel)
        detailsStackView.addArrangedSubview(costContainerView)
        detailsStackView.addArrangedSubview(descriptionLabel)
        
        buttonsStackView.addArrangedSubview(infoButton)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(favouriteButton)
        
        mainStackView.addArrangedSubview(detailsStackView)
        mainStackView.addArrangedSubview(availNowButton)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        detailsView.clipsToBounds = true
        detailsView.layer.cornerRadius = 16
        detailsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        ratingView.clipsToBounds = true
        ratingView.layer.cornerRadius = 16
        
        availNowButton.clipsToBounds = true
        availNowButton.layer.cornerRadius = 24
        
        smileyPointsStackView.setCustomSpacing(8.0, after: pointsIcon)
        smileyPointsStackView.setCustomSpacing(12.0, after: pointsLabel)
        smileyPointsStackView.setCustomSpacing(12.0, after: separatorLabel)
        smileyPointsStackView.setCustomSpacing(4.0, after: amountLabel)
        
    }
    
    func calculateMaxLinesForTitle() -> Int {
        
        let margin: CGFloat = 16
        let maxSize = CGSize(width: UIScreen.main.bounds.size.width - (margin * 2), height: .greatestFiniteMagnitude)
        let charSize = titleLabel.font.lineHeight
        let text = (titleLabel.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: titleLabel.font as Any], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
        
    }
    
    func updateUI(){
        //refresh icon
        if let snap = story?.snaps?[snapIndex] {
            ratingView.isHidden = snap.isOfferStory
            descriptionLabel.isHidden = snap.isOfferStory
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
                if let rating = snap.restaurantRating, rating != 0.0 {
                    ratingView.isHidden = false
                tagLabel.text = String(format:"%.1f",rating)
                }else{
                    ratingView.isHidden = true
                }
            }
            titleLabel.text = snap.storyDetailDescription
            shareButton.isHidden = !(snap.isSharingAllowed ?? false)
            favouriteButton.isHidden = !(snap.isFavoriteAllowed ?? false)
            infoButton.isHidden = !(snap.isInfoAllowed ?? false)
            self.availNowButton.isHidden = !(snap.isbuttonEnabled ?? (snap.redirectionUrl != nil))
            self.availNowButton.setTitle(snap.buttonTitle, for: .normal)
            favouriteButton.setImage(snap.isFavorite ?? false ? #imageLiteral(resourceName: "fvrtIconFilled") : #imageLiteral(resourceName: "fvrtIcon"), for: .normal)
            descriptionLabel.text = snap.promotionText
            buttonsStackView.isHidden = shareButton.isHidden && infoButton.isHidden && favouriteButton.isHidden
        }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            detailsView.leadingAnchor.constraint(equalTo: self.igLeadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: self.igTrailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: self.igBottomAnchor),
            detailsView.topAnchor.constraint(equalTo: ratingView.igBottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: detailsView.igLeadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: detailsView.igTrailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: detailsView.igBottomAnchor),
            mainStackView.topAnchor.constraint(equalTo: detailsView.igTopAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            pointsIcon.heightAnchor.constraint(equalToConstant: 17),
            pointsIcon.widthAnchor.constraint(equalToConstant: 17),
            availNowButton.heightAnchor.constraint(equalToConstant: 48),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 32),
            costContainerView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // MARK: - Rating View Constraints -
        NSLayoutConstraint.activate([
            ratingView.leadingAnchor.constraint(equalTo: self.igLeadingAnchor, constant: 16),
            ratingView.heightAnchor.constraint(equalToConstant: 40),
            ratingView.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            ratingView.topAnchor.constraint(equalTo: self.igTopAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ratingIcon.leadingAnchor.constraint(equalTo: ratingView.igLeadingAnchor, constant: 12),
            ratingIcon.centerYAnchor.constraint(equalTo: ratingView.igCenterYAnchor),
            ratingIcon.heightAnchor.constraint(equalToConstant: 16.4),
            ratingIcon.widthAnchor.constraint(equalToConstant: 17.1)
        ])
        
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: ratingIcon.igTrailingAnchor, constant: 3.4),
            tagLabel.trailingAnchor.constraint(equalTo: ratingView.igTrailingAnchor, constant: -12),
            tagLabel.topAnchor.constraint(equalTo: ratingView.igTopAnchor, constant: 12),
            tagLabel.bottomAnchor.constraint(equalTo: ratingView.igBottomAnchor, constant: -12)
        ])
        
    }
    
}
