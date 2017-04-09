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
    private var score: ScorePartwise?
    var isInEditMode: Bool = false {
        didSet {
            for line in lines {
                line.isInEditMode = isInEditMode
            }
        }
    }
    
    private var previousHeight: CGFloat?
    
    var lines: [LineView] = []
    var lengths: [CGFloat] = [] {
        didSet {
            if let delegate = delegate {
                let maxWidth = (lengths.max() ?? 0) + labelWidth
                delegate.widthWasSet(width: maxWidth)
                
                if maxWidth > self.frame.width {
                    self.frame.size = CGSize(width: maxWidth, height: self.frame.height)
                }
            }
        }
    }
    var labels: [UILabel] = []
    var labelWidth: CGFloat{ return labels.reduce(0) {
            previous, next in
            max(previous, next.frame.width)
        }
    }

    
    /// Set the score to draw
    func setScore(score: ScorePartwise?) {
        guard let score = score else {
            return
        }
        
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        lines.removeAll()
        labels.removeAll()
        self.score = score
        
        for i in 0..<score.parts.count {
            let part = score.parts[i]
            let line = LineView(frame: CGRect.zero)
            line.backgroundColor = UIColor.clear
            line.delegate = self
            line.lengthClosure = {
                self.lengths.append($0)
            }
            
            let processor = MeasureProcessor()
            
            line.measures = processor.process(measures: part.measures)
            
            self.addSubview(line)
            lines.append(line)
            
            let label = UILabel(frame: CGRect.zero)
            label.text = i < score.partList.count ? score.partList[i].partName : part.id
            label.sizeToFit()
            label.textAlignment = .right
            self.addSubview(label)
            labels.append(label)
        }
        
        self.setNeedsDisplay()
    }
    
    
    /// Change the spacing of the lines in the view.
    func changeSpacing(to spacing: Double) {
        let ratio = CGFloat(spacing) / lines[0].spacing
        for line in lines {
            line.frame.size = CGSize(width: ratio * line.frame.width, height: ratio * line.frame.height)
            line.spacing = CGFloat(spacing)
            line.setNeedsDisplay()
        }
    }
    
    
    /// Return an up to date score
    func getScoreForSaving() -> ScorePartwise? {
        guard var score = self.score else {
            return nil
        }
        
        for i in 0..<score.parts.count {
            let line = lines[i]
            
            score.parts[i].measures = line.measures
        }
        
        return score
    }
    
    
    /// Handle a tap (pass on to the LineView or edit the label)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for (i, line) in lines.enumerated() {
            let newPoint = CGPoint(x: line.frame.midX, y: point.y)
            if line.frame.contains(newPoint) {
                if point.x < line.frame.minX {
                    if let vc = delegate as? UIViewController, vc.presentedViewController == nil {
                        vc.presentInputAlert(title: "Set Name", message: "Enter new part name:") {
                            self.labels[i].text = $0
                            
                            if i >= self.score?.partList.count ?? 0 {
                                self.score?.partList.append(ScorePart(id: self.score?.parts[i].id ?? $0, partName: $0))
                            }
                            else {
                                self.score?.partList[i].partName = $0
                            }
                        }
                    }
                    
                    return super.hitTest(point, with: event)
                }
                else {
                    line.tappedX = point.x - 1.5 * margin - labelWidth
                    return line
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    
    /// Set the frame for every line once the frame has been set for self.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = CGRect(x: self.frame.minX + margin, y: self.frame.minY + margin, width: self.frame.width - 2 * margin, height: self.frame.height - 2 * margin)
        let numLines = lines.count
        var totalHeight: CGFloat = 0.0
        
        for i in 0..<numLines {
            let height = 15 * lines[i].spacing
            let y = frame.minY + totalHeight
            totalHeight += height
            
            let labelFrame = labels[i].frame
            let labelY = y + height/2 - labelFrame.height/2
            labels[i].frame = CGRect(x: frame.minX, y: labelY, width: labelWidth, height: labelFrame.height)
            
            let lineX = frame.minX + labelFrame.width + margin/2
            lines[i].frame = CGRect(x: lineX, y: y, width: frame.width, height: height)
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
