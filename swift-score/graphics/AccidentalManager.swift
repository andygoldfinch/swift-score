//
//  AccidentalManager.swift
//  swift-score
//
//  Created by Andy Goldfinch on 03/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

class AccidentalManager {
    private let flats: [PitchStep]  = [.b, .e, .a, .d, .g, .c, .f]
    private let sharps: [PitchStep] = [.f, .c, .g, .d, .a, .e, .b]
    
    /// Does the given note need an accidental?
    func needsAccidental(note: Note, measure: Measure, attributes: Attributes) -> Bool {
        guard let pitch = note.pitch else {
            return false
        }
        
        let fifths: Int = attributes.key?.fifths ?? 0
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
