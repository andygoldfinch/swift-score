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
class LineView: UIView {
    var noteInputViewController: NoteInputViewController?
    var editViewControler: EditViewController?
    
    override var canBecomeFirstResponder: Bool { return true }
    var isInEditMode: Bool = false {
        didSet {
            if isFirstResponder {
                self.resignFirstResponder()
                self.becomeFirstResponder()
            }
        }
    }
    
    override var inputView: UIView? {
        if isInEditMode {
            if editViewControler == nil {
                editViewControler = EditViewController(nibName: "EditViewController", bundle: nil)
                editViewControler?.delegate = self
            }
            
            editViewControler?.measures = measures
            if let x = tappedX, let barlines = previousBarEnds {
                editViewControler?.currentRange = xToRange(tappedX: x, previousBarlines: barlines)
            }
            else {
                editViewControler?.currentRange = BarRange(start: 0, end: measures.count - 1)
            }
            return editViewControler?.view
        }
        else {
            if noteInputViewController == nil {
                noteInputViewController = NoteInputViewController(nibName: "NoteInputViewController", bundle: nil)
                noteInputViewController?.delegate = self
            }
            
            return noteInputViewController?.view
        }
    }
    
    var delegate: LineViewDelegate?
    
    var spacing: CGFloat = 10.0
    var measures: [Measure] = [] {
        didSet {
            self.setNeedsDisplay()
            
            if let editViewControler = editViewControler {
                editViewControler.measures = measures
            }
        }
    }
    
    var lengthClosure: ((CGFloat) -> Void)?
    var finalAttributes: Attributes?
    var selectedRange: BarRange? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var previousBarEnds: [CGFloat]?
    var tappedX: CGFloat? {
        didSet {
            if tappedX != oldValue, let barlines = previousBarEnds, self.isFirstResponder {
                editViewControler?.currentRange = xToRange(tappedX: tappedX!, previousBarlines: barlines)
            }
        }
    }
    
    
    /// Called to draw the view, contains the main rendering loop.
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
        var previousAttributes: Attributes = measures.first?.attributes ?? Attributes.defaultAttributes
        var barEnds: [CGFloat] = [0]
        
        let pathStroke = UIBezierPath()
        let pathFill = UIBezierPath()
        
        // Main rendering loop
        for measure in measures {
            guard let attributes = measure.attributes else {
                fatalError("Attributes is nil: Measure processing should prevent this from ever happening")
            }
            
            // Clefs
            let clef = attributes.clef
            let previousClef = previousAttributes.clef
            let currentClef = attributes.clef ?? Clef(sign: "g", line: 2)
            
            if let clef = clef, previousMeasure == nil || previousClef != clef {
                let y = positionCalculator.getClefPosition(clef: clef)
                let clefView = imageViewGenerator.makeClefView(clef: clef, x: xCounter, y: y)
                xCounter += clefView.frame.width + 0.8 * spacing
                self.addSubview(clefView)
            }
            
            // Time signatures
            let time = attributes.time
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
            let fifths = attributes.key?.fifths
            let previousFifths = previousAttributes.key?.fifths
            
            if let fifths = fifths, previousMeasure == nil || previousFifths != fifths {
                let keyGenerator = KeyGenerator()
                var keyNotes = keyGenerator.makeKey(fifths: fifths, clef: currentClef)
                if previousMeasure != nil && ((previousFifths! < 0 && previousFifths! < fifths) || (previousFifths! > 0 && previousFifths! > fifths)) {
                    keyNotes = keyGenerator.makeNaturals(oldFifths: previousFifths!, newFifths: fifths, clef: currentClef) + keyNotes
                }
                
                for note in keyNotes {
                    let y = positionCalculator.getAccidentalPosition(note: note, clef: currentClef)
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
                if accidentalManager.needsAccidental(note: note, measure: measure, attributes: attributes) {
                    let y = positionCalculator.getAccidentalPosition(note: note, clef: currentClef)
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
                    positionCalculator.getHeadPosition(note: note, clef: currentClef) :
                    positionCalculator.getNotePosition(note: note, clef: currentClef)
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
            barEnds.append(xCounter)
            
            xCounter += spacing
            previousMeasure = measure
            previousAttributes = attributes
            finalAttributes = attributes
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
        previousBarEnds = barEnds
        
        if let range = selectedRange {
            highlight(range: range, barEnds: barEnds, midY: midY)
        }
        
        if lengthClosure != nil {
            lengthClosure!(xCounter)
        }
        
        if finalAttributes == nil {
            finalAttributes = Attributes.defaultAttributes
        }
    }
    
    
    /// Draw a highlight over the given region
    func highlight(range: BarRange, barEnds: [CGFloat], midY: CGFloat) {
        guard range.start < barEnds.count - 1 else {
            return
        }        
        
        let startX = barEnds[range.start]
        let endX = range.end + 1 >= barEnds.count ? barEnds[barEnds.count-1] : barEnds[range.end + 1]
        let width = endX - startX
        let y = midY - 2 * spacing
        let height = 4 * spacing
        
        let highlightFrame = CGRect(x: startX, y: y, width: width, height: height)
        let view = UIView(frame: highlightFrame)
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.18)
        self.addSubview(view)
        self.sendSubview(toBack: view)
    }
    
    
    /// Add a note to the line, including automatically balancing bars.
    func addNote(note: Note) {
        guard !note.chord else {
            let lastIndex = measures.count - 1
            measures[lastIndex].notes.append(note)
            return
        }
        
        let balancer = MeasureBalancer()
        let time = finalAttributes?.time ?? Time(beats: 4, beatType: 4)
        var notes: [Note] = measures.last?.notes ?? []
        let balancedResult = balancer.isBalanced(notes: notes, time: time)
        let isBalanced = balancedResult != .under
        
        if measures.isEmpty || isBalanced {
            let attributes = measures.last?.attributes ?? Attributes.defaultAttributes
            measures.append(Measure(number: "1", attributes: attributes, notes: []))
            notes = []
        }
        
        if balancer.canAdd(note: note, to: notes, time: time) {
            let lastIndex = measures.count - 1
            measures[lastIndex].notes.append(note)
        }
        else {
            let split = balancer.split(note: note, in: notes, time: time)
            let lastIndex = measures.count - 1
            let attributes = measures.last?.attributes ?? Attributes.defaultAttributes
            measures[lastIndex].notes = split.first
            measures.append(Measure(number: "1", attributes: attributes, notes: split.second))
        }
    }
    
    
    /// Called when touches begin on the view.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isFirstResponder {
            self.becomeFirstResponder()
            if let delegate = delegate, let inputView = inputView {
                delegate.keyboardDidShow(height: inputView.frame.height)
            }
        }
    }
    
    
    /// Deselect the range when first responder status is resigned.
    @discardableResult override func resignFirstResponder() -> Bool {
        self.selectedRange = nil
        return super.resignFirstResponder()
    }
    
    
    /// Convert an x coordinate to a BarRange object.
    func xToRange(tappedX: CGFloat, previousBarlines: [CGFloat]) -> BarRange {
        for i in 0..<previousBarlines.count {
            if tappedX > previousBarlines[i] {
                continue
            }
            else {
                return BarRange(start: i-1, end: i-1)
            }
        }
        
        let index = measures.count - 1
        return BarRange(start: index, end: index)
    }
    
    
    /// Delete the given range
    func deleteRange(_ range: BarRange) {
        if measures.count == 1 && measures[0].notes.isEmpty {
            return
        }
        if range.start == 0 && range.count == measures.count {
            measures.removeLast(measures.count-1)
            measures[0].notes.removeAll()
        }
        else {
            measures.removeSubrange(range.start...range.end)
        }
    }
    
    
    /// Duplicate the given range
    func duplicateRange(_ range: BarRange) {
        let bars = getBarsInRange(range)
        print(type(of: bars))
        
        measures.insert(contentsOf: bars, at: range.end+1)
    }
    
    
    /// Move the bars in the given range by the number of positions specified.
    func moveRange(_ range: BarRange, numPlaces: Int) {
        let bars = getBarsInRange(range)
        var newIndex = range.start + numPlaces
        
        if newIndex < 0 {
            newIndex = 0
        }
        
        if newIndex > measures.count {
            newIndex = measures.count
        }
        
        deleteRange(range)
        measures.insert(contentsOf: bars, at: newIndex)
    }
    
    
    /// Change the pitch of the bars in the given range.
    func changeRangePitch(_ range: BarRange, steps: Int) {
        var bars = getBarsInRange(range)
        let pitchChanger = PitchChanger()
        bars = pitchChanger.change(measures: bars, steps: steps)
        
        updateRange(range, with: bars)
    }
    
    
    /// Change the key of the bars in the given range.
    func changeRangeKey(_ range: BarRange, key: Key) {
        var bars = getBarsInRange(range)
        
        for i in 0..<bars.count {
            if bars[i].attributes == nil {
                bars[i].attributes = Attributes()
            }
            
            bars[i].attributes!.key = key
        }
        
        updateRange(range, with: bars)
    }
    
    
    /// Change the time signature of the bars in the given range.
    func changeRangeTime(_ range: BarRange, time: Time) {
        var bars = getBarsInRange(range)
        
        for i in 0..<bars.count {
            if bars[i].attributes == nil {
                bars[i].attributes = Attributes()
            }
            
            bars[i].attributes!.time = time
        }
        
        updateRange(range, with: bars)
    }
    
    
    /// Change the clef of the bars in the given range.
    func changeRangeClef(_ range: BarRange, clef: Clef) {
        var bars = getBarsInRange(range)
        
        for i in 0..<bars.count {
            if bars[i].attributes == nil {
                bars[i].attributes = Attributes()
            }
            
            bars[i].attributes!.clef = clef
        }
        
        updateRange(range, with: bars)
    }
    
    
    /// Replace the bars in the given range with the given bars.
    func updateRange(_ range: BarRange, with bars: [Measure]) {
        deleteRange(range)
        measures.insert(contentsOf: bars, at: range.start)
    }
    
    
    /// Return the bars in the given range.
    func getBarsInRange(_ range: BarRange) -> [Measure] {
        guard range.start >= 0 &&
            range.count > 0 &&
            range.end >= range.start &&
            range.start < measures.count else {
            return []
        }
        
        let start = range.start
        var end = range.end
        
        if end >= measures.count {
            end = measures.count - 1
        }
        
        return Array(measures[start...end])
    }
    
    
    /// Change replace the seleted note with the given note.
    func changeNote(selectedNote: SelectedNote, note: Note) {
        guard selectedNote.absoluteBar < measures.count &&
            selectedNote.note < measures[selectedNote.absoluteBar].notes.count else {
            print("Invalid note change attempted: \(selectedNote)")
            return
        }
        
        measures[selectedNote.absoluteBar].notes[selectedNote.note] = note
    }
}


/// Conform to the NoteInputDelegate protocol
extension LineView: NoteInputDelegate {
    /// Called when a note is typed on the edit keyboard.
    func selectedInput(note: Note) {
        addNote(note: note)
        setNeedsDisplay()
    }
    
    
    /// Called when the keyboard close button is tapped.
    func closeTapped() {
        self.resignFirstResponder()
        selectedRange = nil
        if let delegate = delegate {
            delegate.keyboardDidHide()
        }
    }
    
    
    /// Called when the keyboard backspace button is tapped.
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


/// Conform to the EditDelegate protocol
extension LineView: EditDelegate {
    /// Called when a note is to be changed.
    func noteChanged(selectedNote: SelectedNote, note: Note) {
        changeNote(selectedNote: selectedNote, note: note)
    }

    
    /// Called when the attributes are to be changed.
    internal func attributesChanged(change: AttributeChange) {
        guard let range = selectedRange else {
            print("Error: no range selected")
            return
        }
        
        switch change {
        case let .key(key):
            changeRangeKey(range, key: key)
        case let .time(time):
            changeRangeTime(range, time: time)
        case let .clef(clef):
            changeRangeClef(range, clef: clef)
        }
    }

    
    /// Called when a range is selected or the current range changes.
    func rangeSelected(range: BarRange) {
        self.selectedRange = range
    }
    
    
    /// Called when the current range is to be transformed.
    func rangeTransformed(transformation: RangeTransformation) {
        guard let range = selectedRange else {
            print("Error: no range selected")
            return
        }
        
        switch transformation {
        case let .move(num):
            moveRange(range, numPlaces: num)
        case let .pitchChange(num):
            changeRangePitch(range, steps: num)
        case .delete:
            deleteRange(range)
        case .duplicate:
            duplicateRange(range)
        }
    }
}


protocol LineViewDelegate {
    func keyboardDidShow(height: CGFloat)
    func keyboardDidHide()
}

