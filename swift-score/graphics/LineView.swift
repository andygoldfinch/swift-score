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
    
    override func draw(_ rect: CGRect) {
        if measures.isEmpty {
            return
        }
        
        self.backgroundColor = UIColor.clear
        UIColor.black.setStroke()
        
        let midY = rect.midY
        
        let imageViewGenerator = ImageViewGenerator(spacing: spacing)
        let positionCalculator = PositionCalculator(spacing: spacing, midY: midY)
        let accidentalManager = AccidentalManager()
        
        drawStaff(midY: midY, startX: rect.minX, endX: rect.maxX)
        
        var xCounter: CGFloat = spacing
        var previousMeasure: Measure?
        var currentAttributes: Attributes = Attributes()
        var previousAttributes: Attributes = Attributes()
        
        // Main rendering loop
        for measure in measures {
            previousAttributes = currentAttributes
            currentAttributes = update(currentAttributes: currentAttributes, newAttributes: measure.attributes)
            previousAttributes = previousAttributes == Attributes() ? currentAttributes : previousAttributes
            
            // Clefs
            let clef = currentAttributes.clef
            let previousClef = previousAttributes.clef
            
            if let clef = clef, previousMeasure == nil || previousClef != clef {
                let y = positionCalculator.getClefPosition(clef: clef)
                let clefView = imageViewGenerator.makeClefView(clef: clef, x: xCounter, y: y)
                xCounter += clefView.frame.width + 0.8 * spacing
                self.addSubview(clefView)
            }
            
            // Time signatures
            let time = currentAttributes.time
            let previousTime = previousAttributes.time
            
            if let time = time, previousMeasure == nil || previousTime != time {
                let isWide: Bool = time.beats > 9 || time.beatType > 9
                let width: CGFloat = (isWide ? 3.0 : 2.0) * spacing
                let timeRect = CGRect(x: xCounter - 0.5 * spacing, y: midY - 2 * spacing, width: width, height: 4 * spacing)
                drawTimeSignature(top: time.beats, bottom: time.beatType, rect: timeRect)
                xCounter += width
            }
            
            // Key signatures
            let fifths = currentAttributes.key?.fifths
            let previousFifths = previousAttributes.key?.fifths
            
            if let fifths = fifths, previousMeasure == nil || previousFifths != fifths {
                let keyGenerator = KeyGenerator()
                var keyNotes = keyGenerator.makeKey(fifths: fifths)
                if previousMeasure != nil && ((previousFifths! < 0 && previousFifths! < fifths) || (previousFifths! > 0 && previousFifths! > fifths)) {
                    keyNotes = keyGenerator.makeNaturals(oldFifths: previousFifths!, newFifths: fifths) + keyNotes
                }
                
                for note in keyNotes {
                    let y = positionCalculator.getAccidentalPosition(note: note)
                    let accidentalView = imageViewGenerator.makeAccidentalView(note: note, x: xCounter, y: y)
                    xCounter += accidentalView.frame.width + 0.2 * spacing
                    self.addSubview(accidentalView)
                }
                
                xCounter += 0.2 * spacing
            }
            
            // Note rendering loop
            for note in measure.notes {
                if accidentalManager.needsAccidental(note: note, measure: measure, attributes: currentAttributes) {
                    let y = positionCalculator.getAccidentalPosition(note: note)
                    let accidentalView = imageViewGenerator.makeAccidentalView(note: note, x: xCounter, y: y)
                    xCounter += accidentalView.frame.width + (1/5) * spacing
                    self.addSubview(accidentalView)
                }
                
                let position = positionCalculator.getNotePosition(note: note)
                let noteView = imageViewGenerator.makeNoteView(note: note, x: xCounter, y: position.y)
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

    
    /// Draw the given time signature in the given rect
    func drawTimeSignature(top: Int, bottom: Int, rect: CGRect) {
        let topText = NSString(string: String(top))
        let bottomText = NSString(string: String(bottom))
        
        let font = UIFont(name: "BodoniSvtyTwoITCTT-Bold", size: 2.6 * spacing)
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.center
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
        
        let splitRect = rect.divided(atDistance: rect.height/2.0, from: .minYEdge)
        var topRect = splitRect.slice
        let offset = (font?.ascender ?? 0) - (font?.capHeight ?? 0)
        topRect.origin = CGPoint(x: topRect.origin.x, y: topRect.origin.y - offset)
        topRect.size = CGSize(width: topRect.size.width, height: topRect.height + offset)
        var bottomRect = splitRect.remainder
        bottomRect.origin = CGPoint(x: bottomRect.origin.x, y: bottomRect.origin.y - offset)
        bottomRect.size = CGSize(width: bottomRect.size.width, height: bottomRect.height + offset)
        
        topText.draw(in: topRect, withAttributes: attributes)
        bottomText.draw(in: bottomRect, withAttributes: attributes)
    }
    
    
    /// Return an updated attributes object.
    func update(currentAttributes: Attributes, newAttributes: Attributes?) -> Attributes {
        guard let new = newAttributes else {
            return currentAttributes
        }
        
        var current = currentAttributes
        
        if new.clef != nil && new.clef != current.clef {
            current.clef = new.clef
        }
        
        if new.divisions != nil && new.divisions != current.divisions {
            current.divisions = new.divisions
        }
        
        if new.key != nil && new.key != current.key {
            current.key = new.key
        }
        
        if new.time != nil && new.time != current.time {
            current.time = new.time
        }
        
        return current
    }
    
    
    /// Add a single measure to the LineView, returning false if there is not space to add the given measure.
    func addMeasure(_ measure: Measure) -> Bool {
        measures.append(measure)
        
        // TODO return false if not enough space
        return true
    }

}

