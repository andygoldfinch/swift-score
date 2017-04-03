//
//  EditViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 21/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    var delegate: EditDelegate? = nil
    var measures: [Measure]? = nil {
        didSet {
            configureRangeControls()
            configureAttributeControls()
            configureNoteControls()
            let row = tableView?.indexPathForSelectedRow
            tableView?.reloadData()
            if let row = row {
                tableView?.selectRow(at: row, animated: true, scrollPosition: .none)
            }
        }
    }
    
    var currentRange: BarRange = BarRange(start: 0, end: 0) {
        didSet {
            labelRange?.text = currentRange.toString()
            if let delegate = delegate {
                delegate.rangeSelected(range: currentRange)
            }
            
            stepperStart?.value = Double(currentRange.start)
            stepperEnd?.value = Double(currentRange.end)
            
            configureAttributeControls()
            tableView?.reloadData()
            
            selectedNote = nil
        }
    }
    
    var finalMeasure: Int {
        return (measures?.count ?? 1) - 1
    }
    
    var selectedNote: SelectedNote? {
        didSet {
            configureNoteControls()
        }
    }
    
    var notes: [Note] {
        guard let measures = measures else {
            return []
        }
        
        var notes: [Note] = []
        
        for i in currentRange.start...currentRange.end {
            notes.append(contentsOf: measures[i].notes)
        }
        
        return notes
    }
    
    let beatTypes = [1, 2, 4, 8, 16, 32]
    
    /// Range selection
    @IBOutlet weak var buttonStartToCurrent: UIBarButtonItem!
    @IBOutlet weak var buttonWholeLine: UIBarButtonItem!
    @IBOutlet weak var buttonCurrentBar: UIBarButtonItem!
    @IBOutlet weak var buttonCurrentToEnd: UIBarButtonItem!
    @IBOutlet weak var stepperStart: UIStepper!
    @IBOutlet weak var stepperEnd: UIStepper!
    @IBOutlet weak var labelRange: UILabel!
    
    /// Left button panel
    @IBOutlet weak var buttonUp: InputViewButton!
    @IBOutlet weak var buttonUpOctave: InputViewButton!
    @IBOutlet weak var buttonDown: InputViewButton!
    @IBOutlet weak var buttonDownOctave: InputViewButton!
    @IBOutlet weak var buttonLeft: InputViewButton!
    @IBOutlet weak var buttonStart: InputViewButton!
    @IBOutlet weak var buttonRight: InputViewButton!
    @IBOutlet weak var buttonEnd: InputViewButton!
    @IBOutlet weak var buttonDelete: InputViewButton!
    @IBOutlet weak var buttonDuplicate: InputViewButton!
    
    /// Attribute Editor 
    @IBOutlet weak var labelKey: UILabel!
    @IBOutlet weak var labelTimeTop: UILabel!
    @IBOutlet weak var labelTimeBottom: UILabel!
    @IBOutlet weak var stepperKey: UIStepper!
    @IBOutlet weak var stepperTimeTop: UIStepper!
    @IBOutlet weak var stepperTimeBottom: UIStepper!
    @IBOutlet weak var buttonClefTreble: InputViewButton!
    @IBOutlet weak var buttonClefAlto: InputViewButton!
    @IBOutlet weak var buttonClefBass: InputViewButton!
    
    
    /// Note Editor
    @IBOutlet weak var buttonIsChord: InputViewButton!
    @IBOutlet weak var buttonIsRest: InputViewButton!
    @IBOutlet weak var buttonNoteUp: InputViewButton!
    @IBOutlet weak var buttonNoteDown: InputViewButton!
    @IBOutlet weak var buttonNoteUpOctave: InputViewButton!
    @IBOutlet weak var buttonNoteDownOctave: InputViewButton!
    @IBOutlet weak var buttonFlatDouble: InputViewButton!
    @IBOutlet weak var buttonFlat: InputViewButton!
    @IBOutlet weak var buttonNatural: InputViewButton!
    @IBOutlet weak var buttonSharp: InputViewButton!
    @IBOutlet weak var buttonSharpDouble: InputViewButton!
    @IBOutlet weak var buttonSemibreve: InputViewButton!
    @IBOutlet weak var buttonMinim: InputViewButton!
    @IBOutlet weak var buttonCrotchet: InputViewButton!
    @IBOutlet weak var buttonQuaver: InputViewButton!
    @IBOutlet weak var buttonSemiquaver: InputViewButton!
    @IBOutlet weak var buttonDot0: InputViewButton!
    @IBOutlet weak var buttonDot1: InputViewButton!
    @IBOutlet weak var buttonDot2: InputViewButton!
    
    /// Table View
    @IBOutlet weak var tableView: UITableView!
    
    var currentClefButton: InputViewButton! {
        didSet {
            oldValue?.isToggled = false
            currentClefButton.isToggled = true
        }
    }
    
    var currentAccidentalButton: InputViewButton? {
        didSet {
            oldValue?.isToggled = false
            currentAccidentalButton?.isToggled = true
        }
    }
    
    var currentTypeButton: InputViewButton? {
        didSet {
            oldValue?.isToggled = false
            currentTypeButton?.isToggled = true
        }
    }
    
    var currentDotButton: InputViewButton? {
        didSet {
            oldValue?.isToggled = false
            currentDotButton?.isToggled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureRangeControls()
        configureAttributeControls()
        configureNoteControls()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
    }
    
    func configureRangeControls() {
        guard stepperStart != nil && stepperEnd != nil && labelRange != nil else {
            return
        }
        
        stepperStart?.minimumValue = 0.0
        stepperStart.value = Double(currentRange.start)
        stepperEnd.value = Double(currentRange.end)
        stepperStart?.maximumValue = stepperEnd.value
        stepperEnd.minimumValue = stepperStart.value
        if let count = measures?.count {
            stepperEnd.maximumValue = Double(count) - 1.0
        }
        
        labelRange.text = currentRange.toString()
    }

    
    func configureAttributeControls() {
        guard labelKey != nil && labelTimeTop != nil && labelTimeBottom != nil
            && stepperKey != nil && stepperTimeTop != nil && stepperTimeBottom != nil
            && buttonClefTreble != nil && buttonClefBass != nil && buttonClefAlto != nil else {
            return
        }
        guard currentRange.start < measures?.count ?? 0, let attributes = measures?[currentRange.start].attributes else {
            return
        }
        
        let fifths = attributes.key?.fifths ?? 0
        labelKey.text = string(forFifths: fifths)
        stepperKey.value = Double(fifths)
        
        let time = attributes.time ?? Time(beats: 4, beatType: 4)
        labelTimeTop.text = time.beats.description
        labelTimeBottom.text = time.beatType.description
        stepperTimeTop.value = Double(time.beats)
        stepperTimeBottom.value = Double(beatTypes.index(of: time.beatType) ?? 3)
        
        if attributes.clef?.sign.lowercased() == "c" {
            currentClefButton = buttonClefAlto
        }
        else if attributes.clef?.sign.lowercased() == "f" {
            currentClefButton = buttonClefBass
        }
        else {
            currentClefButton = buttonClefTreble
        }
    }
    
    
    func configureNoteControls() {
        guard buttonIsRest != nil && buttonIsChord != nil && buttonFlatDouble != nil
            && buttonFlat != nil && buttonNatural != nil && buttonSharp != nil
            && buttonSharpDouble != nil && buttonSemibreve != nil && buttonMinim != nil
            && buttonCrotchet != nil && buttonQuaver != nil && buttonSemiquaver != nil
            && buttonDot0 != nil && buttonDot1 != nil && buttonDot2 != nil else {
                return
        }
        guard let selectedNote = selectedNote, let note = getSelectedNote(selectedNote) else {
            setAllNoteButtons(enabled: false)
            return
        }
        
        setAllNoteButtons(enabled: true)
        
        if note.chord! {
            buttonIsChord.isToggled = true
            buttonIsChord.imageView?.image = #imageLiteral(resourceName: "ic_yes")
        }
        else {
            buttonIsChord.isToggled = false
            buttonIsChord.imageView?.image = #imageLiteral(resourceName: "ic_no")
        }
        
        if note.isRest {
            buttonIsRest.isToggled = true
            buttonIsRest.imageView?.image = #imageLiteral(resourceName: "ic_yes")
            
            setPitchButtons(enabled: false)
        }
        else {
            buttonIsRest.isToggled = false
            buttonIsRest.imageView?.image = #imageLiteral(resourceName: "ic_no")
            
            setPitchButtons(enabled: true)
            
            switch note.pitch!.alter ?? 0 {
            case -2:
                currentAccidentalButton = buttonFlatDouble
            case -1:
                currentAccidentalButton = buttonFlat
            case 1:
                currentAccidentalButton = buttonSharp
            case 2:
                currentAccidentalButton = buttonSharpDouble
            default:
                currentAccidentalButton = buttonNatural
            }
            
            switch note.type! {
            case .n1:
                currentTypeButton = buttonSemibreve
            case .n2:
                currentTypeButton = buttonMinim
            case .n4:
                currentTypeButton = buttonCrotchet
            case .n8:
                currentTypeButton = buttonQuaver
            case .n16:
                currentTypeButton = buttonSemiquaver
            default:
                currentTypeButton = nil
            }
            
            switch note.dots! {
            case 0:
                currentDotButton = buttonDot0
            case 1:
                currentDotButton = buttonDot1
            case 2:
                currentDotButton = buttonDot2
            default:
                currentDotButton = nil
            }
        }
        
    }
    
    func setPitchButtons(enabled: Bool) {
        buttonNoteUp.isEnabled = enabled
        buttonNoteDown.isEnabled = enabled
        buttonNoteUpOctave.isEnabled = enabled
        buttonNoteDownOctave.isEnabled = enabled
        
        buttonFlatDouble.isEnabled = enabled
        buttonFlat.isEnabled = enabled
        buttonNatural.isEnabled = enabled
        buttonSharp.isEnabled = enabled
        buttonSharpDouble.isEnabled = enabled
        
        buttonIsChord.isEnabled = enabled
        
        if !enabled {
            currentAccidentalButton = nil
            buttonIsChord.isToggled = false
        }
    }
    
    
    func setAllNoteButtons(enabled: Bool) {
        buttonNoteUp.isEnabled = enabled
        buttonNoteDown.isEnabled = enabled
        buttonNoteUpOctave.isEnabled = enabled
        buttonNoteDownOctave.isEnabled = enabled
        
        buttonFlatDouble.isEnabled = enabled
        buttonFlat.isEnabled = enabled
        buttonNatural.isEnabled = enabled
        buttonSharp.isEnabled = enabled
        buttonSharpDouble.isEnabled = enabled
        
        buttonIsChord.isEnabled = enabled
        buttonIsRest.isEnabled = enabled
        
        buttonSemibreve.isEnabled = enabled
        buttonMinim.isEnabled = enabled
        buttonCrotchet.isEnabled = enabled
        buttonQuaver.isEnabled = enabled
        buttonSemiquaver.isEnabled = enabled
        
        buttonDot0.isEnabled = enabled
        buttonDot1.isEnabled = enabled
        buttonDot2.isEnabled = enabled
        
        if !enabled {
            buttonIsRest.isToggled = false
            buttonIsChord.isToggled = false
            
            currentAccidentalButton?.isToggled = false
            currentTypeButton?.isToggled = false
            currentDotButton?.isToggled = false
        }

    }
    
    
    func getSelectedNote(_ selectedNote: SelectedNote) -> Note? {
        guard let measures = measures else {
            return nil
        }
        
        var barNumber = selectedNote.absoluteBar
        if barNumber >= measures.count {
            barNumber = measures.count - 1
        }
        
        let bar = measures[barNumber]
        let noteNumber = selectedNote.note
        if noteNumber >= bar.notes.count {
            return bar.notes.last
        }
        else {
            return bar.notes[noteNumber]
        }
    }
    
    
    func string(forFifths fifths: Int) -> String {
        if fifths == -1 {
            return "Key of 1 Flat"
        }
        else if fifths < -1 {
            return "Key of \(-fifths) Flats"
        }
        else if fifths > 1 {
            return "Key of \(fifths) Sharps"
        }
        else if fifths == 1 {
            return "Key of 1 Sharp"
        }
        else {
            return "Natural Key"
        }
    }
    

    // MARK: - Ranges
    
    @IBAction func rangeChanged(_ sender: Any) {
        if let stepper = sender as? UIStepper {
            currentRange = BarRange(start: Int(stepperStart.value), end: Int(stepperEnd.value))
            switch stepper {
            case stepperStart:
                stepperEnd.minimumValue = stepperStart.value
            case stepperEnd:
                stepperStart.maximumValue = stepperEnd.value
            default:
                fatalError("Unexpected stepper selected")
            }
        }
        else if let button = sender as? UIBarButtonItem {
            switch button {
            case buttonStartToCurrent:
                currentRange = BarRange(start: 0, end: currentRange.end)
            case buttonWholeLine:
                currentRange = BarRange(start: 0, end: finalMeasure)
            case buttonCurrentBar:
                currentRange = BarRange(start: currentRange.start, end: currentRange.start)
            case buttonCurrentToEnd:
                currentRange = BarRange(start: currentRange.start, end: finalMeasure)
            default:
                fatalError("Unhandled range button")
            }
        }
        
    }
    
    
    func setMaxRanges(bars count: Int) {
        guard count >= 0 else {
            return
        }
        
        stepperStart?.minimumValue = 0.0
    }
    
    
    func moveCurrentRange(places: Int) {
        currentRange = BarRange(start: currentRange.start + places, end: currentRange.end + places)
    }
    
    // MARK: - Left Buttons
    
    @IBAction func leftButtonPressed(_ sender: InputViewButton) {
        guard let delegate = delegate else {
            return
        }
        
        switch sender {
        case buttonUp:
            delegate.rangeTransformed(transformation: .pitchChange(1))
        case buttonUpOctave:
            delegate.rangeTransformed(transformation: .pitchChange(7))
        case buttonDown:
            delegate.rangeTransformed(transformation: .pitchChange(-1))
        case buttonDownOctave:
            delegate.rangeTransformed(transformation: .pitchChange(-7))
        case buttonLeft:
            delegate.rangeTransformed(transformation: .move(-1))
            moveCurrentRange(places: -1)
        case buttonStart:
            delegate.rangeTransformed(transformation: .move(-currentRange.start))
            moveCurrentRange(places: -currentRange.start)
        case buttonRight:
            delegate.rangeTransformed(transformation: .move(1))
            moveCurrentRange(places: 1)
        case buttonEnd:
            if let count = measures?.count {
                let distanceToEnd = count - 1 - currentRange.end
                delegate.rangeTransformed(transformation: .move(distanceToEnd))
                moveCurrentRange(places: distanceToEnd)
            }
        case buttonDelete:
            delegate.rangeTransformed(transformation: .delete)
        case buttonDuplicate:
            delegate.rangeTransformed(transformation: .duplicate)
        default:
            fatalError("Unhandled left button pressed")
        }
    }
    
    @IBAction func attributeButtonPressed(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        
        if let stepper = sender as? UIStepper {
            switch stepper {
            case stepperKey:
                let newKey = Key(fifths: Int(stepperKey.value))
                delegate.attributesChanged(change: .key(newKey))
            case stepperTimeTop, stepperTimeBottom:
                let newTop = Int(stepperTimeTop.value)
                let newBottom = beatTypes[Int(stepperTimeBottom.value)]
                let newTime = Time(beats: newTop, beatType: newBottom)
                delegate.attributesChanged(change: .time(newTime))
            default:
                fatalError("Unhanded Stepper")
            }
        }
        else if let button = sender as? InputViewButton {
            switch button {
            case buttonClefTreble:
                let newClef = Clef(sign: "G", line: 2)
                delegate.attributesChanged(change: .clef(newClef))
            case buttonClefAlto:
                let newClef = Clef(sign: "C", line: 3)
                delegate.attributesChanged(change: .clef(newClef))
            case buttonClefBass:
                let newClef = Clef(sign: "F", line: 4)
                delegate.attributesChanged(change: .clef(newClef))
            default:
                fatalError("Unhandled Button")
            }
        }
    }
    
    
    @IBAction func noteButtonPressed(_ sender: InputViewButton) {
        guard let selectedNote = selectedNote, var note = getSelectedNote(selectedNote) else {
            return
        }
        
        switch sender {
        case buttonIsRest:
            if note.isRest {
                note.pitch = Pitch(step: .c, octave: 4, alter: 0)
            }
            else {
                note.pitch = nil
            }
        case buttonSemibreve:
            note.type = .n1
        case buttonMinim:
            note.type = .n2
        case buttonCrotchet:
            note.type = .n4
        case buttonQuaver:
            note.type = .n8
        case buttonSemiquaver:
            note.type = .n16
        case buttonDot0:
            note.dots = 0
        case buttonDot1:
            note.dots = 1
        case buttonDot2:
            note.dots = 2
        default:
            break
        }
        
        if let pitch = note.pitch {
            switch sender {
            case buttonIsChord:
                note.chord = !note.chord
            case buttonNoteUp:
                let pitchChanger = PitchChanger()
                note.pitch = pitchChanger.change(pitch: pitch, steps: 1)
            case buttonNoteDown:
                let pitchChanger = PitchChanger()
                note.pitch = pitchChanger.change(pitch: pitch, steps: -1)
            case buttonNoteUpOctave:
                let pitchChanger = PitchChanger()
                note.pitch = pitchChanger.change(pitch: pitch, steps: 8)
            case buttonNoteDownOctave:
                let pitchChanger = PitchChanger()
                note.pitch = pitchChanger.change(pitch: pitch, steps: -8)
            case buttonFlatDouble:
                note.pitch?.alter = -2
            case buttonFlat:
                note.pitch?.alter = -1
            case buttonNatural:
                note.pitch?.alter = 0
            case buttonSharp:
                note.pitch?.alter = 1
            case buttonSharpDouble:
                note.pitch?.alter = 2
            default:
                break
            }
        }
        else {
            print("Pitch button pressed on note without pitch")
        }
        
        if let delegate = delegate {
            delegate.noteChanged(selectedNote: selectedNote, note: note)
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.closeTapped()
        }
    }
}

extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedNote = rowToSelectedNote(row: indexPath.row) {
            self.selectedNote = selectedNote
        }
        else {
            fatalError("Impossible note selected (Cannot get note from tableview row)")
        }
    }
    
    func rowToSelectedNote(row: Int) -> SelectedNote? {
        guard let measures = measures else {
            return nil
        }
        var count = 0
        
        for i in currentRange.start...currentRange.end {
            let measure = measures[i]
            if row - count < measure.notes.count {
                return SelectedNote(relativeBar: i - currentRange.start, note: row - count, range: currentRange)
            }
            else {
                count += measure.notes.count
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return buttonUp.frame.height - 3
    }
}

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteTableViewCell
        
        let note = notes[indexPath.row]
        cell.labelPitch.text = note.pitch?.description ?? "Rest"
        
        cell.labelType.text =  note.type.description
        
        return cell
    }
}

protocol EditDelegate {
    func closeTapped()
    func rangeSelected(range: BarRange)
    func rangeTransformed(transformation: RangeTransformation)
    func attributesChanged(change: AttributeChange)
    func noteChanged(selectedNote: SelectedNote, note: Note)
}

enum RangeTransformation {
    case pitchChange(Int)
    case move(Int)
    case delete
    case duplicate
}

enum AttributeChange {
    case key(Key)
    case time(Time)
    case clef(Clef)
}

