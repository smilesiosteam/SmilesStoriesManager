//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 24/02/2023.
//

import Foundation
import UIKit

@IBDesignable
class StoriesButtonPrimary: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            setup()
        }
    }

    // MARK: - Properties

    @IBInspectable var isUpperCased: Bool = false {
        didSet {
            setup()
        }
    }

    @IBInspectable var normalState: Bool = false {
        didSet {
            setup()
        }
    }

    fileprivate func setup() {
        commonInit()
        setEnabled(true)
        setSelected(selected: false)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setEnabled(true)
        setSelected(selected: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setEnabled(true)
        setSelected(selected: false)
    }

    func commonInit() {
        layer.cornerRadius = cornerRadius
        backgroundColor = Colors.appPurpleColor1
        tintColor = UIColor.clear
        titleLabel?.font = UIFont(name: Font.bold, size: 14)
        setTitle(titleLabel?.text, for: .normal)
        setTitleColor(UIColor.white, for: .normal)

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        commonInit()
        setEnableState(enabled)
    }

    override open func didMoveToWindow() {
        if normalState {
            setTitle(title(for: .normal), for: .normal)
        } else {
            setTitle(isUpperCased ? title(for: .normal)?.uppercased() : capitalizingFirstLetter(string: title(for: .normal) ?? ""), for: .normal)
        }
    }
    
    private func capitalizingFirstLetter(string: String) -> String {
        return string.prefix(1).uppercased() + string.lowercased().dropFirst()
    }

    func setEnableState(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            alpha = 1.0
            layer.cornerRadius = cornerRadius
            backgroundColor = Colors.appPurpleColor1
            tintColor = UIColor.clear
            titleLabel?.font = UIFont(name: Font.bold, size: 14)
            setTitleColor(UIColor.white, for: .normal)

        } else {
//            alpha = 0.5
            layer.cornerRadius = cornerRadius
            backgroundColor = Colors.appButtonDisabledColor.withAlphaComponent(0.3)
            titleLabel?.font = UIFont(name: Font.bold, size: 14)
            setTitleColor(Colors.appGreyColor_128.withAlphaComponent(0.5), for: .normal)
        }
    }

    func setSelected(selected: Bool) {
//        commonInit()
//        if selected {
//            layer.cornerRadius = cornerRadius
//            backgroundColor = UIColor.clear
//            tintColor = UIColor.clear
//
//            titleLabel?.font = UIFont.appBoldFont(withSize: 17)
//            setTitleColor(UIColor.white, for: .normal)
//             setTitle(titleLabel?.text?.uppercased(), for: .normal)
//
//            translatesAutoresizingMaskIntoConstraints = false
//            heightAnchor.constraint(equalToConstant: 70).isActive = true
//
//        } else {
//            layer.cornerRadius = cornerRadius
//            backgroundColor = UIColor.clear
//            titleLabel?.font = UIFont.appBoldFont(withSize: 17)
//            layer.borderWidth = 1
//            setTitleColor(UIColor.white, for: .normal)
//            layer.borderColor = UIColor.selectedButtonColor().cgColor
//             setTitle(titleLabel?.text?.uppercased(), for: .normal)
//
//            translatesAutoresizingMaskIntoConstraints = false
//            heightAnchor.constraint(equalToConstant: 70).isActive = true
//        }
    }

    func setUnfocusedAppearance() {
//        backgroundColor = UIColor.white
//        setTitleColor(UIColor.appPrimaryColor(), for: .normal)
//        layer.borderColor = UIColor.appPrimaryColor().cgColor
//        layer.borderWidth = 0.5
    }
    
    struct Font {
        static let regular = "Montserrat-Regular"
        static let bold = "Montserrat-Bold"
        static let semiBold = "Montserrat-Semibold"
    }
    
    struct Colors {
        static var appPurpleColor1: UIColor { return UIColor(red: 135.0 / 255.0, green: 84.0 / 255.0, blue: 161.0 / 255.0, alpha: 1.0) }
        static var appButtonDisabledColor: UIColor { return UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0) }
        static var appGreyColor_128: UIColor { return UIColor(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0) }
    }
    
}
