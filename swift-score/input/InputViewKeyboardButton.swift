//
//  InputViewKeyboardButton.swift
//  swift-score
//
//  Created by Andy Goldfinch on 08/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class InputViewKeyboardButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var borderColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var isWhite: Bool = true
    @IBInspectable var isLeft: Bool = false
    @IBInspectable var isRight: Bool = false
    
    
    /// Called by the system whenever it is necessary to layout the subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners()
        
        if isWhite {
            self.backgroundColor = UIColor.white
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }
        else {
            self.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        }
    }
    
    
    /// Round the corners of the button.
    func roundCorners() {
        var corners: UIRectCorner = [.bottomLeft, .bottomRight]
        
        if isLeft {
            corners.insert(.topLeft)
        }
        if isRight {
            corners.insert(.topRight)
        }
        
        let radius = isWhite ? 2 * cornerRadius : 1.5 * cornerRadius
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
