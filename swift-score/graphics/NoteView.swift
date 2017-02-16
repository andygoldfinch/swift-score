//
//  NoteView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 16/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

@IBDesignable class NoteView: UIView {
    @IBInspectable var isFilled: Bool = true
    @IBInspectable var color: UIColor = UIColor.black
    
    var headCenter: CGPoint?
    
    override func draw(_ rect: CGRect) {
        let size = rect.height
        
        let headSize = size/3.3
        let lineWidth = headSize / 8
        let headRect = CGRect(x: rect.minX + (lineWidth / 2), y: (rect.maxY - headSize - (lineWidth / 2)), width: headSize, height: headSize)
        let headPath = UIBezierPath(ovalIn: headRect)
        headPath.lineWidth = lineWidth
        headCenter = CGPoint(x: headRect.midX, y: headRect.midY)
        
        color.setStroke()
        headPath.stroke()
        if isFilled {
            color.setFill()
            headPath.fill()
        }
        
        let stemPath = UIBezierPath()
        let stemX = headRect.maxX
        stemPath.move(to: CGPoint(x: stemX, y: headRect.midY))
        stemPath.addLine(to: CGPoint(x: stemX, y: rect.minY))
        stemPath.lineWidth = lineWidth
        stemPath.stroke()
    }
 

}
