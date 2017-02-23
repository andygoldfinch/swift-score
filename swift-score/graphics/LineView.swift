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
        UIColor.black.setStroke()
        
        let midY = rect.midY
        
        drawStaff(midY: midY, startX: rect.minX, endX: rect.maxX)
        
        var xCounter: CGFloat = spacing
        
        for measure in measures {
            for note in measure.notes {
                let position = getPosition(note: note, midY: midY)
                let noteView = makeImageView(note: note, x: xCounter, y: position.y)
                let noteSpacing = noteView.frame.width + spacing + (CGFloat(note.dots) * 0.5 * spacing)
                self.addSubview(noteView)
                
                drawLedgerLines(lines: position.lines, x: xCounter, midY: midY)
                drawDots(note: note, noteFrame: noteView.frame)
 
                xCounter += noteSpacing
            }
 
            drawBarline(x: xCounter, midY: midY)
            
            xCounter += spacing
        }
    }
 
    
    /// Draw the a representation of the given ledger lines object.
    func drawLedgerLines(lines: LedgerLines?, x: CGFloat, midY: CGFloat) {
        if let ledger = lines {
            var y = ledger.above ? (midY -  3 * spacing) : (midY + 3 * spacing)
            let space = ledger.above ? -spacing : spacing
            let startX = x - 0.4 * spacing
            let endX = x + 1.4 * spacing
            
            let path = UIBezierPath()
            
            for _ in 1...ledger.count {
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: endX, y: y))
                
                y += space
            }
            
            path.stroke()
        }
    }
    
    
    /// Draw the dots for the given note, relative to the given note frame.
    func drawDots(note: Note, noteFrame: CGRect) {
        if note.dots > 0 {
            var x: CGFloat!
            if note.type == .n1 {
                x = noteFrame.maxX + 0.4 * spacing
            }
            else {
                x = noteFrame.minX + 1.4 * spacing
            }
            
            let y: CGFloat!
            if note.pitch == nil {
                y = noteFrame.minY + (4/3) * spacing
            }
            else if note.pitch!.octave >= 5 {
                y = noteFrame.minY + (2/3) * spacing
            }
            else {
                y = noteFrame.maxY - (1/3) * spacing
            }
            
            for _ in 1...note.dots {
                drawDot(x: x, y: y)
                x = x + 0.5 * spacing
            }
        }
    }
    
    
    /// Draw a dot at the given location.
    func drawDot(x: CGFloat, y: CGFloat) {
        let frame = CGRect(x: x, y: y, width: spacing/4, height: spacing/4)
        let path = UIBezierPath(ovalIn: frame)
        path.stroke()
        path.fill()
    }
    
    
    /// Draw a barline in the given place.
    func drawBarline(x: CGFloat, midY: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: midY - 2 * spacing))
        path.addLine(to: CGPoint(x: x, y: midY + 2 * spacing))
        path.stroke()
    }
    
    
    /// Draw the staff
    func drawStaff(midY: CGFloat, startX: CGFloat, endX: CGFloat) {
        let ys: [CGFloat] = [midY - 2 * spacing,
                             midY - spacing,
                             midY,
                             midY + spacing,
                             midY + 2 * spacing]
        
        let linePath = UIBezierPath()
        
        for y in ys {
            linePath.move(to: CGPoint(x: startX, y: y))
            linePath.addLine(to: CGPoint(x: endX, y: y))
        }
        
        linePath.stroke()
    }
    
    
    /// Return an image representing the given note.
    func makeImageView(note: Note, x: CGFloat, y: CGFloat) -> UIImageView {
        let view = UIImageView()
        let isSemibreve: Bool = note.type == .n1 && !note.isRest
        let height: CGFloat = isSemibreve ? spacing : 4 * spacing
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
            return (midY - 2 * spacing, nil) //TODO add offset for rest height
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
            default:
                name = "crotchet"
            }
            
            
            if let pitch = note.pitch {
                if pitch.octave >= 5 {
                    name.append("-down")
                }
                else {
                    name.append("-up")
                }
            }
            else {
                name.append("-rest")
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


