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
    
    static let widthRatio: CGFloat = 3.3
    static let radiusRatio: CGFloat = 2.0
    
    var headCenter: CGPoint
    var height: CGFloat
    var stemUp: Bool
    
    var width: CGFloat {
        return height / NoteView.widthRatio
    }
    
    var headRadius: CGFloat {
        return width / NoteView.radiusRatio
    }
    
    init(headCenter: CGPoint, height: CGFloat, stemUp: Bool) {
        self.headCenter = headCenter
        self.height = height
        self.stemUp = stemUp
        
        let width = height / NoteView.widthRatio
        let radius = width / NoteView.radiusRatio
        
        let x: CGFloat = headCenter.x - radius
        var y: CGFloat!
        
        if stemUp {
            y = headCenter.y - height - radius
        }
        else {
            y = headCenter.y - radius
        }
        
        let frame =  CGRect(x: x, y: y, width: width, height: height)

        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented in NoteView class")
    }
    
    override func draw(_ rect: CGRect) {
        let headSize = width
        let lineWidth = headSize / 8
        
        let headRect = CGRect(x: rect.minX + (lineWidth / 2), y: (rect.maxY - headSize - (lineWidth / 2)), width: headSize, height: headSize)
        let headPath = UIBezierPath(ovalIn: headRect)
        headPath.lineWidth = lineWidth
        
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
