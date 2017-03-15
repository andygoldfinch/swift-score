//
//  ScoreView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 16/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    @IBInspectable var margin: CGFloat = 32.0
    
    var delegate: ScoreViewDelegate?
    
    private var previousHeight: CGFloat?
    
    var lines: [LineView] = []
    var lengths: [CGFloat] = [] {
        didSet {
            if let delegate = delegate {
                let maxWidth = lengths.max() ?? 0
                delegate.widthWasSet(width: maxWidth)
                
                if maxWidth > self.frame.width {
                    self.frame.size = CGSize(width: maxWidth, height: self.frame.height)
                }
            }
        }
    }

    func drawScore(score: ScorePartwise?) {
        guard let score = score else {
            return
        }
        
        for i in 0..<score.parts.count {
            let part = score.parts[i]
            let line = LineView(frame: CGRect.zero)
            line.backgroundColor = UIColor.clear
            line.delegate = self
            line.lengthClosure = {
                self.lengths.append($0)
            }
            
            for measure in part.measures {
                if !line.addMeasure(measure) {
                    print("Measure not added to line: \(measure)")
                }
            }
            
            self.addSubview(line)
            lines.append(line)
        }
        
    }
    
    func changeSpacing(to spacing: Double) {
        let ratio = CGFloat(spacing) / lines[0].spacing
        for line in lines {
            line.frame.size = CGSize(width: ratio * line.frame.width, height: ratio * line.frame.height)
            line.spacing = CGFloat(spacing)
            line.setNeedsDisplay()
        }
    }
    
    
    /// Select a line based on y position, ignoring x (fixes an issue with autolayout causing some incorrect frames)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for line in lines {
            let newPoint = CGPoint(x: line.frame.midX, y: point.y)
            if line.frame.contains(newPoint) {
                return line
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    
    /// Set the frame for every line once the frame has been set for self.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Frame created here with manual offsets to compensate for a bug where some layout constraints of self are applied twice.
        //let frame = CGRect(x: self.frame.minX - 36, y: self.frame.minY - 28, width: self.frame.width, height: self.frame.height)
        let frame = CGRect(x: self.frame.minX + margin, y: self.frame.minY + margin, width: self.frame.width - 2 * margin, height: self.frame.height - 2 * margin)
        let numLines = lines.count
        var totalHeight: CGFloat = 0.0
        
        for i in 0..<numLines {
            //let height: CGFloat = frame.height/CGFloat(numLines)
            let height = 20 * lines[i].spacing
            let y = frame.minY + totalHeight
            totalHeight += height
            lines[i].frame = CGRect(x: frame.minX, y: y, width: frame.width, height: height)
        }
        
        self.frame.size = CGSize(width: self.frame.width, height: totalHeight)
        
        if let delegate = delegate, totalHeight != previousHeight {
            delegate.heightWasSet(height: totalHeight)
            previousHeight = totalHeight
        }
    }

}

extension ScoreView: LineViewDelegate {
    func keyboardDidHide() {
        if let delegate = delegate {
            delegate.keyboardDidHide()
        }
    }
    
    func keyboardDidShow(height: CGFloat) {
        if let delegate = delegate {
            delegate.keyboardDidShow(height: height)
        }
    }
}

protocol ScoreViewDelegate {
    func heightWasSet(height: CGFloat)
    func widthWasSet(width: CGFloat)
    func keyboardDidShow(height: CGFloat)
    func keyboardDidHide()
    
}
