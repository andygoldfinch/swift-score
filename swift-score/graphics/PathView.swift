//
//  StaffView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 04/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

/// A class to fill and/or stroke the given paths in the given colour.
class PathView: UIView {
    var color: UIColor = UIColor.black
    var pathStroke: UIBezierPath?
    var pathFill: UIBezierPath?
    
    
    /// Stroke the pathStroke and fill the pathFill with the set colour.
    override func draw(_ rect: CGRect) {
        if let path = pathStroke {
            color.setStroke()
            path.stroke()
        }
        
        if let path = pathFill {
            color.setStroke()
            path.stroke()
            path.fill()
        }
    }
}
