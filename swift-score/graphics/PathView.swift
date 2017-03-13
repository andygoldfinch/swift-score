//
//  StaffView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 04/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class PathView: UIView {
    var color: UIColor = UIColor.black
    var pathStroke: UIBezierPath?
    var pathFill: UIBezierPath?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
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
