//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 24/02/2023.
//

import Foundation
import UIKit

class StoriesGradientUtility {
    static let shared = StoriesGradientUtility()
    private init(){ }
    
    func getGradientStartAndEndPoint (withDirection direction: String) -> (startPoint: CGPoint, endPoint: CGPoint) {
        
        var startPoint: CGPoint?
        var endPoint: CGPoint?
        
        switch direction.lowercased() {
            
        case "bottom":
            // bottom to top
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 0.0)
            break
            
        case "left":
            // left to right
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
            
        case "right":
            // right to left
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
            break
            
        case "bottom_right":
            // bottomRight to topLeft
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 0.0)
            break
            
        case "bottom_left":
            // bottomLeft top topRight
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
            break
            
        case "top_left":
            // topLeft to bottomRight
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
            break
            
        case "top_right":
            // topRight to bottomLeft
            startPoint = CGPoint(x: 1.0, y: 0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
            break
            
        default:
            // top to bottom
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        
        return (startPoint!, endPoint!)
    }
    
    func getGradientLayer(forView: UIView, colors: [CGColor], direction: String) -> CAGradientLayer{
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colors
        gradient.locations = [0.0 , 1.0]
        
        let gradientPoints = StoriesGradientUtility.shared.getGradientStartAndEndPoint(withDirection: direction)
        gradient.startPoint = gradientPoints.startPoint
        gradient.endPoint = gradientPoints.endPoint
        
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: forView.frame.size.width, height: forView.frame.size.height)
        return gradient
    }
    
    func removeGradientLayersFrom(view: UIView) {
        
        var gradientLayers = [CAGradientLayer]()
        
        if let subLayers = view.layer.sublayers {
            for layer in subLayers {
                if layer is CAGradientLayer {
                    gradientLayers.append(layer as! CAGradientLayer)
                }
            }
        }
        
        for layer in gradientLayers {
            layer.removeFromSuperlayer()
        }
    }
}
