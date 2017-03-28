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
            configureControls()
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
        }
    }
    var finalMeasure: Int {
        return (measures?.count ?? 1) - 1
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureControls()
    }
    
    func configureControls() {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

enum RangeTransformation {
    case pitchChange(Int)
    case move(Int)
    case delete
    case duplicate
}


