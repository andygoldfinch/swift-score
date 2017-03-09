//
//  NoteInputViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 06/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class NoteInputViewController: UIViewController {
    var delegate: NoteInputDelegate? = nil
    
    // Length
    @IBOutlet weak var buttonSemibreve: InputViewButton!
    @IBOutlet weak var buttonMinim: InputViewButton!
    @IBOutlet weak var buttonCrotchet: InputViewButton!
    @IBOutlet weak var buttonQuaver: InputViewButton!
    @IBOutlet weak var buttonSemiquaver: InputViewButton!
    
    // Other
    @IBOutlet weak var buttonRest: InputViewButton!
    @IBOutlet weak var buttonChord: InputViewButton!
    
    // Pitches
    @IBOutlet weak var buttonC4: InputViewKeyboardButton!
    @IBOutlet weak var buttonD4: InputViewKeyboardButton!
    @IBOutlet weak var buttonE4: InputViewKeyboardButton!
    
    @IBOutlet weak var buttonF4: InputViewKeyboardButton!
    @IBOutlet weak var buttonG4: InputViewKeyboardButton!
    @IBOutlet weak var buttonA4: InputViewKeyboardButton!
    @IBOutlet weak var buttonB4: InputViewKeyboardButton!
    
    @IBOutlet weak var buttonC5: InputViewKeyboardButton!
    @IBOutlet weak var buttonD5: InputViewKeyboardButton!
    @IBOutlet weak var buttonE5: InputViewKeyboardButton!
    
    @IBOutlet weak var buttonC4s: InputViewKeyboardButton!
    @IBOutlet weak var buttonD4s: InputViewKeyboardButton!
    
    @IBOutlet weak var buttonF4s: InputViewKeyboardButton!
    @IBOutlet weak var buttonG4s: InputViewKeyboardButton!
    @IBOutlet weak var buttonA4s: InputViewKeyboardButton!

    @IBOutlet weak var buttonC5s: InputViewKeyboardButton!
    @IBOutlet weak var buttonD5s: InputViewKeyboardButton!
    
    // Octaves
    @IBOutlet weak var buttonPlus2: InputViewButton!
    @IBOutlet weak var buttonPlus1: InputViewButton!
    @IBOutlet weak var buttonZero: InputViewButton!
    @IBOutlet weak var buttonMinus1: InputViewButton!
    @IBOutlet weak var buttonMinus2: InputViewButton!
    
    // Toggled values
    var currentTypeButton: InputViewButton! {
        didSet {
            oldValue?.isToggled = false
            currentTypeButton.isToggled = true
        }
    }
    
    var currentType: NoteType {
        switch currentTypeButton {
        case buttonSemibreve:
            return .n1
        case buttonMinim:
            return .n2
        case buttonQuaver:
            return .n8
        case buttonSemiquaver:
            return .n16
        default:
            return .n4
        }
    }
    
    var currentOctaveButton: InputViewButton! {
        didSet {
            oldValue?.isToggled = false
            currentOctaveButton.isToggled = true
        }
    }
    
    var currentOctave: Int {
        switch currentOctaveButton {
        case buttonPlus2:
            return 2
        case buttonPlus1:
            return 1
        case buttonMinus1:
            return -1
        case buttonMinus2:
            return -2
        default:
            return 0
        }
    }
    
    var currentDots: Int = 0
    
    var isChord: Bool {
        return buttonChord.isToggled
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentTypeButton = buttonCrotchet
        currentOctaveButton = buttonZero
    }
    
    
    @IBAction func buttonTapped(sender: InputViewButton) {
        if sender == buttonSemibreve
            || sender == buttonMinim
            || sender == buttonCrotchet
            || sender == buttonQuaver
            || sender == buttonSemiquaver {
            currentTypeButton = sender
        }
        else if sender == buttonPlus2
            || sender == buttonPlus1
            || sender == buttonZero
            || sender == buttonMinus1
            || sender == buttonMinus2 {
            currentOctaveButton = sender
        }
        else if sender == buttonChord {
            sender.toggle()
        }
        else if sender == buttonRest && delegate != nil {
            var note = Note()
            note.type = currentType
            note.chord = isChord
            note.dots = currentDots
            
            delegate!.selectedInput(note: note)
        }
    }
    
    /// Handle a note being pressed.
    @IBAction func noteTapped(_ sender: InputViewKeyboardButton) {
        var note = Note()
        
        switch sender {
        case buttonC4:
            note.pitch = Pitch(step: .c, octave: 4, alter: 0)
        case buttonD4:
            note.pitch = Pitch(step: .d, octave: 4, alter: 0)
        case buttonE4:
            note.pitch = Pitch(step: .e, octave: 4, alter: 0)
        case buttonF4:
            note.pitch = Pitch(step: .f, octave: 4, alter: 0)
        case buttonG4:
            note.pitch = Pitch(step: .g, octave: 4, alter: 0)
        case buttonA4:
            note.pitch = Pitch(step: .a, octave: 4, alter: 0)
        case buttonB4:
            note.pitch = Pitch(step: .b, octave: 4, alter: 0)
        case buttonC5:
            note.pitch = Pitch(step: .c, octave: 5, alter: 0)
        case buttonD5:
            note.pitch = Pitch(step: .d, octave: 5, alter: 0)
        case buttonE5:
            note.pitch = Pitch(step: .e, octave: 5, alter: 0)
        case buttonC4s:
            note.pitch = Pitch(step: .c, octave: 4, alter: 1)
        case buttonD4s:
            note.pitch = Pitch(step: .d, octave: 4, alter: 1)
        case buttonF4s:
            note.pitch = Pitch(step: .f, octave: 4, alter: 1)
        case buttonG4s:
            note.pitch = Pitch(step: .g, octave: 4, alter: 1)
        case buttonA4s:
            note.pitch = Pitch(step: .a, octave: 4, alter: 1)
        case buttonC5s:
            note.pitch = Pitch(step: .c, octave: 5, alter: 1)
        case buttonD5s:
            note.pitch = Pitch(step: .d, octave: 5, alter: 1)
        default:
            fatalError("Error: unhandled note button")
        }
        
        note.pitch!.octave! += currentOctave
        note.type = currentType
        note.chord = isChord
        note.dots = currentDots
        
        if let delegate = delegate {
            delegate.selectedInput(note: note)
        }
    }
    
    @IBAction func closeTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.closeTapped()
        }
    }
    
    @IBAction func backspaceTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.backspaceTapped()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol NoteInputDelegate {
    func selectedInput(note: Note)
    func closeTapped()
    func backspaceTapped()
}

enum NoteInputType {
    case length(NoteType)
    case rest(NoteType)
    case accent
    case text
    case pitch(Pitch)
    case octave(Int)
    case other
}
