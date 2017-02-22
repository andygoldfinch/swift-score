//
//  LineView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 20/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

/// This class draws a single line of music, represented as a list of measures. 
/// Measures should be added one at a time, and the add method will return false when there is no space left on this line.
class LineView: UIView {
    private var measures: [Measure] = []
    
    /// Add a single measure to the LineView, returning false if there is not space to add the given measure.
    func addMeasure(_ measure: Measure) -> Bool {
        measures.append(measure)
        
        // TODO return false if not enough space
        return true
    }

    override func draw(_ rect: CGRect) {
        if measures.isEmpty {
            return
        }
        
        print("LineView rect: minX = \(rect.minX), minY = \(rect.minY), maxX = \(rect.maxX), maxY = \(rect.maxY)")
        
        self.backgroundColor = UIColor.clear
        
        let spacing: CGFloat = 10.0
        let center = rect.midY
        let ys: [CGFloat] = [center - 2 * spacing,
                             center - spacing,
                             center,
                             center + spacing,
                             center + 2 * spacing]
        
        let startX = rect.minX
        let endX = rect.maxX
        
        let linePath = UIBezierPath()
        
        for i in 0...4 {
            linePath.move(to: CGPoint(x: startX, y: ys[i]))
            linePath.addLine(to: CGPoint(x: endX, y: ys[i]))
        }
        
        UIColor.black.setStroke()
        linePath.stroke()
        
        var xCounter: CGFloat = 10.0
        
        for measure in measures {
            for note in measure.notes {
                
                let y = ys[0]
                /*let noteView = NoteView(headCenter: CGPoint(x: xCounter, y: y), height: 4 * spacing, stemUp: true)
                noteView.backgroundColor = UIColor.clear
                self.addSubview(noteView)*/
                
                let noteView = makeImageView(for: note, atX: xCounter, withSpacing: spacing, withYs: ys)
                self.addSubview(noteView)
                xCounter += 20.0
            }
            
            xCounter += 10.0
            let barline = UIBezierPath()
            barline.move(to: CGPoint(x: xCounter, y: ys[0]))
            barline.addLine(to: CGPoint(x: xCounter, y: ys[4]))
            barline.stroke()
            xCounter += 10.0
        }
    }
    
    
    /// Return an image representing the given note.
    func makeImageView(for note: Note, atX x: CGFloat, withSpacing spacing: CGFloat, withYs ys: [CGFloat]) -> UIImageView {
        let view = UIImageView()
        let y = getY(note: note, midY: ys[2], spacing: spacing)
        view.frame = CGRect(x: x, y: y, width: 3*spacing, height: 4*spacing)
        view.image = getImage(for: note)
        view.contentMode = UIViewContentMode.scaleAspectFit
        return view
    }
    
 
    /// Return the y position for the given note.
    func getY(note: Note, midY: CGFloat, spacing: CGFloat) -> CGFloat {
        let noteOffset = 3.5 * spacing
        var stepY: CGFloat!
        
        if let pitch = note.pitch {
            
            let step = pitch.step!
            
            switch step {
            case .c:
                stepY = midY + (3 * spacing) - noteOffset
            case .d:
                stepY = midY + (2.5 * spacing) - noteOffset
            case .e:
                stepY = midY + (2 * spacing) - noteOffset
            case .f:
                stepY = midY + (1.5 * spacing) - noteOffset
            case .g:
                stepY = midY + (1 * spacing) - noteOffset
            case .a:
                stepY = midY + (0.5 * spacing) - noteOffset
            default:
                stepY = midY - noteOffset
            }
            
            let octaveSpace = 3.5 * spacing
            let octave = pitch.octave - 4
            
            stepY = stepY - (CGFloat(octave) * octaveSpace)
            
            return stepY
        }
        else {
            return midY //TODO add offset for rest height
        }
    }
    
    /// Return an image for the given note
    func getImage(for note: Note) -> UIImage? {
        var name: String!
        if let type = note.type {
            switch type {
            case .n16:
                name = "semiquaver"
            case .n8:
                name = "quaver"
            case .n4:
                name = "crotchet"
            case .n2:
                name = "minim"
            case .n1:
                name = "semibreve"
                return UIImage(named: name)
            default:
                name = "crotchet"
            }
            
            name.append("-up") //TODO choose direction based on pitch
            
            return UIImage(named: name)
        }
        else {
            return nil
        }
    }
}


