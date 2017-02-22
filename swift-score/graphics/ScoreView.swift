//
//  ScoreView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 16/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    var lines: [LineView] = []

    func drawScore(score: ScorePartwise?) {
        guard let score = score else {
            return
        }
        
        for i in 0..<score.parts.count {
            let part = score.parts[i]
            let line = LineView(frame: CGRect.zero)
            line.backgroundColor = UIColor.clear
            
            for measure in part.measures {
                if !line.addMeasure(measure) {
                    print("Measure not added to line: \(measure)")
                }
            }
            
            self.addSubview(line)
            lines.append(line)
        }
        
    }
    
    
    /// Set the frame for every line once the frame has been set for self.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Frame created here with manual offsets to compensate for a bug where some layout constraints of self are applied twice.
        let frame = CGRect(x: self.frame.minX - 36, y: self.frame.minY - 28, width: self.frame.width, height: self.frame.height)
        let numLines = lines.count
        
        for i in 0..<numLines {
            let height: CGFloat = frame.height/CGFloat(numLines)
            let y = frame.minY + CGFloat(i) * height
            lines[i].frame = CGRect(x: frame.minX, y: y, width: frame.width, height: height)
        }
    }

}
