//
//  ScoreView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 16/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class ScoreView: UIView {

    func drawScore(score: ScorePartwise?) {
        let padding: CGFloat = 20.0
        var rect = CGRect(x: self.frame.minX + padding - self.frame.width/20, y: self.frame.minY, width: self.frame.width/20, height: self.frame.height/10)
        
        for _ in 1...4 {
            rect.origin.x += self.frame.width/20
            let note = NoteView(frame: rect)
            note.backgroundColor = UIColor.clear
            self.addSubview(note)
        }
    }

}
