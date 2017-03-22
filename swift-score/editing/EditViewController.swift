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
            if let count = measures?.count {
                setMaxRanges(bars: count)
            }
        }
    }
    var currentMeasure: Int = 0 {
        didSet {
            currentRange = BarRange(start: currentMeasure, end: currentMeasure)
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
        return (measures?.count ?? currentMeasure + 1) - 1
    }
    
    @IBOutlet weak var buttonStartToCurrent: UIBarButtonItem!
    @IBOutlet weak var buttonWholeLine: UIBarButtonItem!
    @IBOutlet weak var buttonCurrentBar: UIBarButtonItem!
    @IBOutlet weak var buttonCurrentToEnd: UIBarButtonItem!
    @IBOutlet weak var stepperStart: UIStepper!
    @IBOutlet weak var stepperEnd: UIStepper!
    @IBOutlet weak var labelRange: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        stepperStart.value = Double(currentRange.start)
        stepperEnd.value = Double(currentRange.end)
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
                currentRange = BarRange(start: 0, end: currentMeasure)
            case buttonWholeLine:
                currentRange = BarRange(start: 0, end: finalMeasure)
            case buttonCurrentBar:
                currentRange = BarRange(start: currentMeasure, end: currentMeasure)
            case buttonCurrentToEnd:
                currentRange = BarRange(start: currentMeasure, end: finalMeasure)
            default:
                fatalError("Unhandled button")
            }
        }
        
        
    }
    
    func setMaxRanges(bars count: Int) {
        guard count >= 0 else {
            return
        }
        
        stepperStart?.minimumValue = 0.0
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
}
