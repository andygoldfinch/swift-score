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
        }
    }
    var finalMeasure: Int {
        return (measures?.count ?? 1) - 1
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
    
    var currentClefButton: InputViewButton! {
        didSet {
            oldValue?.isToggled = false
            currentClefButton.isToggled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureRangeControls()
        configureAttributeControls()
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
    

    
    @IBAction func closeTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.closeTapped()
        }
    }
}

protocol EditDelegate {
    func closeTapped()
    func rangeSelected(range: BarRange)
    func rangeTransformed(transformation: RangeTransformation)
    func attributesChanged(change: AttributeChange)
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

