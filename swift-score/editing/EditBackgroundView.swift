//
//  EditBackgroundView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 29/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

@IBDesignable class EditBackgroundView: UIView {
    @IBInspectable var roundTopLeft: Bool = true
    @IBInspectable var roundTopRight: Bool = true
    @IBInspectable var roundBottomLeft: Bool = true
    @IBInspectable var roundBottomRight: Bool = true
    @IBInspectable var cornerRadius: CGFloat = 5.0
    
    
    /// Called whenever the subviews of the view are to be layout.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners()
        self.backgroundColor = UIColor.white
    }

    
    /// Round the corners of this view
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
