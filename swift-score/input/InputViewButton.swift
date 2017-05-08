//
//  InputViewButton.swift
//  swift-score
//
//  Created by Andy Goldfinch on 08/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class InputViewButton: UIButton {
    @IBInspectable var roundTopLeft: Bool = true
    @IBInspectable var roundTopRight: Bool = true
    @IBInspectable var roundBottomLeft: Bool = true
    @IBInspectable var roundBottomRight: Bool = true
    @IBInspectable var cornerRadius: CGFloat = 6
    @IBInspectable var margin: CGFloat = 6
    
    var isToggled: Bool = false {
        didSet {
            if isToggled {
                backgroundColor = UIColor(white: 0.88, alpha: 1.0)
            }
            else {
                backgroundColor = UIColor.white
            }
        }
    }
    
    
    /// Called by the system whenever it is necessary to layout the subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners()
        imageEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom:margin, right: margin)
        imageView?.contentMode = .scaleAspectFit
    }

    
    /// Switch the state of the button's isToggled property.
    func toggle() {
        isToggled = !isToggled
    }
    
    
    /// Round the corners of the button.
    func roundCorners() {
        var corners: UIRectCorner = []
        
        if roundTopLeft {
            corners.insert(.topLeft)
        }
        if roundTopRight {
            corners.insert(.topRight)
        }
        if roundBottomLeft {
            corners.insert(.bottomLeft)
        }
        if roundBottomRight {
            corners.insert(.bottomRight)
        }
        
        let radius = cornerRadius
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
