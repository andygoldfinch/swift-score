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
    
    private let flats: [PitchStep]  = [.b, .e, .a, .d, .g, .c, .f]
    private let sharps: [PitchStep] = [.f, .c, .g, .d, .a, .e, .b]
    
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
        var previousMeasure: Measure?
        
        // Main rendering loop
        for measure in measures {
            // Key signatures
            let fifths = measure.attributes.key.fifths
            let previousFifths = previousMeasure?.attributes.key.fifths
            if previousMeasure == nil ||  previousFifths != fifths {
                var keyNotes = KeyBuilder().makeKey(fifths: measure.attributes.key.fifths)
                if previousMeasure != nil && ((previousFifths! < 0 && previousFifths! < fifths!) || (previousFifths! > 0 && previousFifths! > fifths!)) {
                    keyNotes = KeyBuilder().makeNaturals(oldFifths: previousFifths!, newFifths: fifths!) + keyNotes
                }
                
                for note in keyNotes {
                    let y = getAccidentalPosition(note: note, midY: midY)
                    let accidentalView = makeAccidentalImageView(note: note, x: xCounter, y: y)
                    xCounter += accidentalView.frame.width + 0.2 * spacing
                    self.addSubview(accidentalView)
                }
                
                xCounter += 0.2 * spacing
            }
            
            // Note rendering loop
            for note in measure.notes {
                if needsAccidental(note: note, measure: measure) {
                    let y = getAccidentalPosition(note: note, midY: midY)
                    let accidentalView = makeAccidentalImageView(note: note, x: xCounter, y: y)
                    xCounter += accidentalView.frame.width + (1/5) * spacing
                    self.addSubview(accidentalView)
                }
                
                let position = getPosition(note: note, midY: midY)
                let noteView = makeImageView(note: note, x: xCounter, y: position.y)
                let noteSpacing = noteView.frame.width + spacing + (CGFloat(note.dots) * 0.5 * spacing)
                self.addSubview(noteView)
                
                drawLedgerLines(lines: position.lines, type: note.type, x: xCounter, midY: midY)
                drawDots(note: note, noteFrame: noteView.frame)
 
                xCounter += noteSpacing
            }
 
            drawBarline(x: xCounter, midY: midY)
            
            xCounter += spacing
            previousMeasure = measure
        }
    }
 
    
    /// Draw the a representation of the given ledger lines object.
    func drawLedgerLines(lines: LedgerLines?, type: NoteType, x: CGFloat, midY: CGFloat) {
        if let ledger = lines {
            var y = ledger.above ? (midY -  3 * spacing) : (midY + 3 * spacing)
            let space = ledger.above ? -spacing : spacing
            let startX = x - 0.4 * spacing
            let length: CGFloat = type == .n1 ? 2.0 : 1.4
            let endX = x + length * spacing
            
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
    
    
    /// Return an image view representing the accidental for the given note.
    func makeAccidentalImageView(note: Note, x: CGFloat, y: CGFloat) -> UIImageView {
        guard let alter = note.pitch?.alter else {
            return UIImageView()
        }
        
        let view = UIImageView()
        let height: CGFloat!
        
        if alter <  0 {
            height = 2.4 * spacing
        }
        else if alter < 2 {
            height = 2.6 * spacing
        }
        else {
            height = spacing
        }
        
        view.frame = CGRect(x: x, y: y, width: 2 * spacing, height: height)
        
        if let image = getAccidentalImage(alter: alter) {
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
    
    
    /// Return the y position for the accidental for the given note.
    func getAccidentalPosition(note: Note, midY: CGFloat) -> CGFloat {
        guard let pitch = note.pitch else {
            return midY
        }
        guard let alter = pitch.alter else {
            return midY
        }
        
        let offset: CGFloat!
        var stepY: CGFloat!
        
        if alter >= 2 {
            offset = 0.5 * spacing
        }
        else if alter < 0 {
            offset = 1.7 * spacing
        }
        else {
            offset = 1.3 * spacing
        }
        
        let step = pitch.step!
        
        switch step {
        case .c:
            stepY = midY + (3 * spacing) - offset
        case .d:
            stepY = midY + (2.5 * spacing) - offset
        case .e:
            stepY = midY + (2 * spacing) - offset
        case .f:
            stepY = midY + (1.5 * spacing) - offset
        case .g:
            stepY = midY + (1 * spacing) - offset
        case .a:
            stepY = midY + (0.5 * spacing) - offset
        default:
            stepY = midY - offset
        }
        
        let octaveSpace = 3.5 * spacing
        let octave = pitch.octave - 4
        
        stepY = stepY - (CGFloat(octave) * octaveSpace)
        
        return stepY
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
    
    
    /// Return an image for the accidental of the given note.
    func getAccidentalImage(alter: Int) -> UIImage? {
        switch alter {
        case -2:
            return UIImage(named: "flat-double")
        case -1:
            return UIImage(named: "flat")
        case 1:
            return UIImage(named: "sharp")
        case 2:
            return UIImage(named: "sharp-double")
        default:
            return UIImage(named: "natural")
        }
    }
    
    
    /// Does the given note need an accidental?
    func needsAccidental(note: Note, measure: Measure) -> Bool {
        guard let pitch = note.pitch else {
            return false
        }
        
        let fifths: Int = measure.attributes.key.fifths
        var key = fifths > 0 ? sharps[0..<fifths] : flats[0..<(-fifths)]
        if fifths == 0 {
            key = ArraySlice<PitchStep>()
        }
        
        let alterNotInKey = !alterInKey(note: note, key: Array(key), isSharp: fifths > 0)
        let measureHasDifferentAlters = hasDifferentAlters(pitch: pitch, measure: measure)

        return alterNotInKey || measureHasDifferentAlters
    }
    
    
    /// Check if the alter of a given note is in the key signature.
    func alterInKey(note: Note, key: [PitchStep], isSharp: Bool) -> Bool {
        guard let alter = note.pitch?.alter else {
            return false
        }
        
        switch alter {
        case 1:
            return isSharp && key.contains(note.pitch!.step)
        case 0:
            return !key.contains(note.pitch!.step)
        case -1:
            return !isSharp && key.contains(note.pitch!.step)
        default:
            return false
        }
    }
    
    
    /// Check if there are any notes in the measure with the same pitch and a different alter
    func hasDifferentAlters(pitch: Pitch, measure: Measure) -> Bool {
        for note in measure.notes {
            if note.pitch?.step == pitch.step && note.pitch?.octave == pitch.octave && note.pitch?.alter != pitch.alter {
                return true
            }
        }
        
        return false
    }

}

struct LedgerLines {
    let count: Int
    let above: Bool
    var below: Bool {
        return !above
    }
}


