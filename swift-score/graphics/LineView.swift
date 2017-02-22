//
//  LineView.swift
//  swift-score
//
//  Created by Andy Goldfinch on 20/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit
import AVFoundation

/// This class draws a single line of music, represented as a list of measures. 
/// Measures should be added one at a time, and the add method will return false when there is no space left on this line.
class LineView: UIView {
    let spacing: CGFloat = 10.0
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
        
        self.backgroundColor = UIColor.clear
        
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
            let path = UIBezierPath()
            
            for note in measure.notes {
                let position = getPosition(note: note, midY: ys[2])
                let noteView = makeImageView(for: note, x: xCounter, y: position.y)
                let noteSpacing = noteView.frame.width + spacing
                self.addSubview(noteView)
                
                if let ledger = position.lines {
                    var y = ledger.above ? (ys[0] - spacing) : (ys[4] + spacing)
                    let space = ledger.above ? -spacing : spacing
                    let startX = xCounter - 0.4 * spacing
                    let endX = xCounter + 1.4 * spacing
                    
                    for _ in 1...ledger.count {
                        path.move(to: CGPoint(x: startX, y: y))
                        path.addLine(to: CGPoint(x: endX, y: y))
                        
                        y += space
                    }
                }
                
                if note.dots > 0 {
                    var x: CGFloat!
                    if note.type == .n1 {
                        x = noteSpacing - 0.6 * spacing
                    }
                    else {
                        x = xCounter + 1.4 * spacing
                    }
                    
                    let y: CGFloat!
                    if note.pitch?.octave ?? 0 >= 5 {
                        y = noteView.frame.minY + (2/3) * spacing
                    }
                    else {
                        y = noteView.frame.maxY - (1/3) * spacing
                    }
                    
                    for _ in 1...note.dots {
                        drawDot(x: x, y: y)
                        x = x + 0.5 * spacing
                    }
                    
                    xCounter += CGFloat(note.dots) * 0.5 * spacing
                }
                
                xCounter += noteSpacing
            }
            
            path.move(to: CGPoint(x: xCounter, y: ys[0]))
            path.addLine(to: CGPoint(x: xCounter, y: ys[4]))
            path.stroke()
            xCounter += spacing
        }
    }
    
    
    /// Draw a dot at the given location
    func drawDot(x: CGFloat, y: CGFloat) {
        let frame = CGRect(x: x, y: y, width: spacing/4, height: spacing/4)
        let path = UIBezierPath(ovalIn: frame)
        path.stroke()
        path.fill()
    }
    
    
    /// Return an image representing the given note.
    func makeImageView(for note: Note, x: CGFloat, y: CGFloat) -> UIImageView {
        let view = UIImageView()
        let height: CGFloat = note.type == .n1 ? spacing : 4 * spacing
        view.frame = CGRect(x: x, y: y, width: 3*spacing, height: height)
        
        if let image = getImage(for: note) {
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)
            view.frame = CGRect(x: x, y: y, width: rect.width, height: height)
            view.image = image
            view.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        return view
    }
    
 
    /// Return the y position for the given note.
    func getPosition(note: Note, midY: CGFloat) -> (y: CGFloat, lines: LedgerLines?) {
        let octave = note.pitch?.octave ?? 0
        let stemUp: Bool = octave < 5 && note.type != .n1
        let noteOffset: CGFloat =  stemUp ? 3.5 * spacing : 0.5 * spacing
        var stepY: CGFloat!
        var lines: LedgerLines? = nil
        
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
            
            if stepY < (midY - (2.5 * spacing) - noteOffset) {
                let numLines = Int((midY - stepY - noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: true)
            }
            else if stepY > (midY + (2.5 * spacing) - noteOffset) {
                let numLines = Int((stepY - midY + noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: false)
            }
            
            return (stepY, lines)
        }
        else {
            return (midY, nil) //TODO add offset for rest height
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
            
            if note.pitch?.octave ?? 0 >= 5 {
                name.append("-down") //TODO choose direction based on pitch
            }
            else {
                name.append("-up")
            }
            
            return UIImage(named: name)
        }
        else {
            return nil
        }
    }
}

struct LedgerLines {
    let count: Int
    let above: Bool
    var below: Bool {
        return !above
    }
}


