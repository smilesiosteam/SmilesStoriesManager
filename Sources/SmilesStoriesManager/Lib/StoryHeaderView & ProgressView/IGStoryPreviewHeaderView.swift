//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import SmilesFontsManager

protocol StoryPreviewHeaderProtocol: AnyObject {
    func didTapCloseButton()
}

fileprivate let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class IGStoryPreviewHeaderView: UIView {
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    var snapIndex: Int = 0 {
        didSet{
            udpateUI()
        }
    }
    
    public var story:Story? {
        didSet {
            snapsPerStory  = (story?.snaps?.count ?? 0) < maxSnaps ? (story?.snaps?.count ?? 0) : maxSnaps
        }
    }
    fileprivate var progressView: UIView?
    internal let snaperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let detailsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.alignment = .fill
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let snaperNameLabel: UILabel = {
        let label = UILabel()
        label.fontTextStyle = .smilesHeadline5
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "whiteCross"), for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    // MARK: - SubDetailsView -
    private let subDetailsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.alignment = .leading
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let promotionLabel: UILabel = {
        let label = UILabel()
        label.text = "Promotion"
        label.fontTextStyle = .smilesTitle3
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "e7e5e7")
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "a6a8b3")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Rating View -
    private let ratingView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 2
        view.alignment = .fill
        view.distribution = .fillProportionally
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
        label.fontTextStyle = .smilesTitle3
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "e7e5e7")
        return label
    }()
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
//        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func udpateUI() {
        if let snap = story?.snaps?[snapIndex] {
            promotionLabel.isHidden = snap.isOfferStory
            ratingView.isHidden = snap.isOfferStory
            separator.isHidden = snap.isOfferStory
            if !snap.isOfferStory {
                if let rating = snap.restaurantRating, rating != 0.0 {
                    ratingView.isHidden = false
                    if !promotionLabel.isHidden && snap.promotionText != nil {
                        separator.isHidden = false
                    } else {
                        separator.isHidden = true
                    }
                tagLabel.text = String(format:"%.1f",rating)
                } else{
                    ratingView.isHidden = true
                    separator.isHidden = true
                }
            }
            subDetailsStackView.isHidden = promotionLabel.isHidden && ratingView.isHidden && separator.isHidden
            layoutIfNeeded()
            promotionLabel.text = snap.promotionText
            snaperNameLabel.text = snap.title
            if let picture = story?.snaps?[snapIndex].logoUrl {
                snaperImageView.setImage(url: picture)
            }
        }
    }
    private func loadUIElements(){
        backgroundColor = .clear
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailsStackView)
        addSubview(closeButton)
        
        ratingView.addArrangedSubview(ratingIcon)
        ratingView.addArrangedSubview(tagLabel)
        
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        subDetailsStackView.addArrangedSubview(promotionLabel)
        subDetailsStackView.addArrangedSubview(separator)
        subDetailsStackView.addArrangedSubview(ratingView)
        subDetailsStackView.addArrangedSubview(spacerView)
        
        detailsStackView.addArrangedSubview(snaperNameLabel)
        detailsStackView.addArrangedSubview(subDetailsStackView)
    }
    private func installLayoutConstraints(){
        //Setting constraints for progressView
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.igLeadingAnchor.constraint(equalTo: self.igLeadingAnchor, constant: 8),
            pv.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            self.igTrailingAnchor.constraint(equalTo: pv.igTrailingAnchor, constant: 8),
            pv.heightAnchor.constraint(equalToConstant: 4)
            ])
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 48),
            snaperImageView.heightAnchor.constraint(equalToConstant: 48),
            snaperImageView.igLeadingAnchor.constraint(equalTo: self.igLeadingAnchor, constant: 16),
            snaperImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 24)
            ])
        layoutIfNeeded() //To make snaperImageView round. Adding this to somewhere else will create constraint warnings.
        
        //Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailsStackView.igLeadingAnchor.constraint(equalTo: snaperImageView.igTrailingAnchor, constant: 9),
            detailsStackView.igCenterYAnchor.constraint(equalTo: snaperImageView.igCenterYAnchor)
            ])
        
        //Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.igLeadingAnchor.constraint(equalTo: detailsStackView.igTrailingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: self.snaperImageView.topAnchor),
            closeButton.igTrailingAnchor.constraint(equalTo: self.igTrailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        
        NSLayoutConstraint.activate([
            ratingIcon.heightAnchor.constraint(equalToConstant: 12),
            ratingIcon.widthAnchor.constraint(equalToConstant: 12),
            separator.widthAnchor.constraint(equalToConstant: 2),
            separator.heightAnchor.constraint(equalToConstant: 12)
        ])
        
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! IGSnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    public func clearSnapProgressor(at index:Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    public func createSnapProgressors(){
        print("Progressor count: \(getProgressView.subviews.count)")
        let padding: CGFloat = 3 //GUI-Padding
        let height: CGFloat = 2
        var pvIndicatorArray: [IGSnapProgressIndicatorView] = []
        var pvArray: [IGSnapProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory{
            let pvIndicator = IGSnapProgressIndicatorView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.4))
            pvIndicatorArray.append(pvIndicator)
            
            let pv = IGSnapProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            pvIndicator.addSubview(applyProperties(pv))
            pvArray.append(pv)
        }
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                pvIndicator.leftConstraiant = pvIndicator.igLeadingAnchor.constraint(equalTo: self.getProgressView.igLeadingAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: self.getProgressView.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                    ])
                if pvIndicatorArray.count == 1 {
                    pvIndicator.rightConstraiant = self.getProgressView.igTrailingAnchor.constraint(equalTo: pvIndicator.igTrailingAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }else {
                let prePVIndicator = pvIndicatorArray[index-1]
                pvIndicator.widthConstraint = pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                pvIndicator.leftConstraiant = pvIndicator.igLeadingAnchor.constraint(equalTo: prePVIndicator.igTrailingAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: prePVIndicator.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthConstraint!
                    ])
                if index == pvIndicatorArray.count-1 {
                    pvIndicator.rightConstraiant = self.igTrailingAnchor.constraint(equalTo: pvIndicator.igTrailingAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }
        }
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.widthConstraint = pv.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                pv.igLeadingAnchor.constraint(equalTo: pvIndicator.igLeadingAnchor),
                pv.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                pv.igTopAnchor.constraint(equalTo: pvIndicator.igTopAnchor),
                pv.widthConstraint!
                ])
        }
    }
}
