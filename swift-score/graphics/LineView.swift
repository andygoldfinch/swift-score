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
    var noteInputViewController: NoteInputViewController?
    override var canBecomeFirstResponder: Bool { return true }
    override var inputView: UIView? {
        if noteInputViewController == nil {
            noteInputViewController = NoteInputViewController(nibName: "NoteInputViewController", bundle: nil)
            noteInputViewController?.delegate = self
        }
        
        return noteInputViewController?.view
    }
    
    var delegate: LineViewDelegate?
    
    var spacing: CGFloat = 10.0
    fileprivate var measures: [Measure] = []
    var lengthClosure: ((CGFloat) -> Void)?
    var finalAttributes: Attributes!
    
    override func draw(_ rect: CGRect) {
        if measures.isEmpty {
            return
        }
        
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        self.backgroundColor = UIColor.clear
        UIColor.black.setStroke()
        
        let midY = rect.midY
        
        let imageViewGenerator = ImageViewGenerator(spacing: spacing)
        let pathGenerator = PathGenerator(spacing: spacing)
        let positionCalculator = PositionCalculator(spacing: spacing, midY: midY)
        let accidentalManager = AccidentalManager()
        
        var xCounter: CGFloat = spacing
        var previousMeasure: Measure?
        var currentAttributes: Attributes = Attributes()
        var previousAttributes: Attributes = Attributes()
        
        let pathStroke = UIBezierPath()
        let pathFill = UIBezierPath()
        
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
                
                let imageViews = imageViewGenerator.makeTimeViews(top: time.beats, bottom: time.beatType, rect: timeRect)
                self.addSubview(imageViews.top)
                self.addSubview(imageViews.bottom)
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
            var previousNotes: [Note] = []
            var previousNoteX: CGFloat = 0.0
            
            for note in measure.notes {
                let isChord = note.chord ?? false

                // Accidentals
                if accidentalManager.needsAccidental(note: note, measure: measure, attributes: currentAttributes) {
                    let y = positionCalculator.getAccidentalPosition(note: note)
                    let accidentalView = imageViewGenerator.makeAccidentalView(note: note, x: xCounter, y: y)
                    let width = accidentalView.frame.width + (1/5) * spacing
                    if isChord {
                        accidentalView.frame.origin.x = previousNoteX - width
                    }
                    else {
                        xCounter += width
                    }
                    self.addSubview(accidentalView)
                }
                
                // Notes
                let position = isChord ?
                    positionCalculator.getHeadPosition(note: note) :
                    positionCalculator.getNotePosition(note: note)
                let noteView = isChord ?
                    imageViewGenerator.makeHeadView(note: note, x: previousNoteX, y: position.y) :
                    imageViewGenerator.makeNoteView(note: note, x: xCounter, y: position.y)
                let noteSpacing = noteView.frame.width + spacing + (CGFloat(note.dots) * 0.5 * spacing)
                self.addSubview(noteView)
            
                // Ledger lines
                let ledgerX = isChord ? previousNoteX : xCounter
                let ledgerPath = pathGenerator.makeLedgerLines(lines: position.lines, type: note.type, x: ledgerX, midY: midY)
                pathStroke.append(ledgerPath)
                
                // Dots
                if !isChord {
                    let dotPath = pathGenerator.makeDots(note: note, noteFrame: noteView.frame)
                    pathFill.append(dotPath)
                }
                
                if !isChord {
                    previousNoteX = xCounter
                    xCounter += noteSpacing
                }
                
                if !note.chord {
                    previousNotes = [note]
                }
                else {
                    previousNotes.append(note)
                }
            }
 
            // Barline
            let barlinePath = pathGenerator.makeBarline(x: xCounter, midY: midY)
            pathStroke.append(barlinePath)
            
            xCounter += spacing
            previousMeasure = measure
            finalAttributes = currentAttributes
        }

        frame.size = CGSize(width: xCounter, height: rect.height)
        let staffPath = pathGenerator.makeStaff(midY: midY, startX: rect.minX, endX: xCounter - spacing)
        pathStroke.append(staffPath)
        let staff = PathView(frame: CGRect(x: rect.minX, y: rect.minY, width: xCounter, height: rect.height))
        staff.pathStroke = pathStroke
        staff.pathFill = pathFill
        staff.backgroundColor = UIColor.clear
        self.addSubview(staff)
        staff.setNeedsDisplay()
        
        if lengthClosure != nil {
            lengthClosure!(xCounter)
        }
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
    
    func addNote(note: Note) {
        guard !note.chord else {
            let lastIndex = measures.count - 1
            measures[lastIndex].notes.append(note)
            return
        }
        
        let balancer = MeasureBalancer()
        let time = finalAttributes.time ?? Time(beats: 4, beatType: 4)
        var notes: [Note] = measures.last?.notes ?? []
        let balancedResult = balancer.isBalanced(notes: notes, time: time)
        let isBalanced = balancedResult != .under
        
        if measures.isEmpty || isBalanced {
            measures.append(Measure(number: "1", attributes: nil, notes: []))
            notes = []
        }
        
        if balancer.canAdd(note: note, to: notes, time: time) {
            let lastIndex = measures.count - 1
            measures[lastIndex].notes.append(note)
        }
        else {
            let split = balancer.split(note: note, in: notes, time: time)
            print("Notes split: \(split)")
            let lastIndex = measures.count - 1
            measures[lastIndex].notes = split.first
            measures.append(Measure(number: "1", attributes: nil, notes: split.second))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isFirstResponder {
            self.becomeFirstResponder()
            if let delegate = delegate, let inputView = inputView {
                delegate.keyboardDidShow(height: inputView.frame.height)
            }
        }
    }
    
}

extension LineView: NoteInputDelegate {
    func selectedInput(note: Note) {
        addNote(note: note)
        setNeedsDisplay()
    }
    
    func closeTapped() {
        self.resignFirstResponder()
        if let delegate = delegate {
            delegate.keyboardDidHide()
        }
    }
    
    func backspaceTapped() {
        if !measures.isEmpty {
            if  !measures[measures.count-1].notes.isEmpty {
                measures[measures.count-1].notes.removeLast()
            }
            if (measures.last?.notes.isEmpty)! && measures.count > 1 {
                measures.removeLast()
            }
            setNeedsDisplay()
        }
    }
}

protocol LineViewDelegate {
    func keyboardDidShow(height: CGFloat)
    func keyboardDidHide()
}

