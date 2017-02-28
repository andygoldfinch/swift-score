//
//  KeyBuilder.swift
//  swift-score
//
//  Created by Andy Goldfinch on 28/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

/// A class to build lists of notes in certain keys, for the purpose of displaying key signatures.
class KeyBuilder {
    
    /// Generate a list of notes in the key represented by the given fifths value.
    func makeKey(fifths: Int) -> [Note] {
        let key = fifths > 0 ? getAllSharps()[0..<fifths] : getAllFlats()[0..<(-fifths)]
        var notes: [Note] = []
        
        for item in key {
            notes.append(Note(chord: false, pitch: item, duration: 0, type: .invalid, dots: 0))
        }
        
        return notes
    }
    
    
    /// Generate a list of naturals for use before the displaying of a new key.
    func makeNaturals(oldFifths: Int, newFifths: Int) -> [Note] {
        var new: Int = newFifths
        if oldFifths > 0 && new < 0 {
            new = 0
        }
        else if oldFifths < 0 && new > 0 {
            new = 0
        }
        
        new = abs(new)
        
        let key = oldFifths > 0 ? getAllSharps(true)[new..<oldFifths] : getAllFlats(true)[new..<(-oldFifths)]
        var notes: [Note] = []
        
        for item in key {
            notes.append(Note(chord: false, pitch: item, duration: 0, type: .invalid, dots: 0))
        }
        
        return notes
    }
    
    
    /// Return a list of the pitches of all flats, in the standard order.
    private func getAllFlats(_ isNatural: Bool = false) -> [Pitch] {
        var flats: [Pitch] = []
        let alter: Int = isNatural ? 0 : -1
        
        flats.append(Pitch(step: .b, octave: 4, alter: alter))
        flats.append(Pitch(step: .e, octave: 5, alter: alter))
        flats.append(Pitch(step: .a, octave: 4, alter: alter))
        flats.append(Pitch(step: .d, octave: 5, alter: alter))
        flats.append(Pitch(step: .g, octave: 4, alter: alter))
        flats.append(Pitch(step: .c, octave: 5, alter: alter))
        flats.append(Pitch(step: .f, octave: 4, alter: alter))
        
        return flats
    }
    
    
    /// Return a list of the pitches of all sharps, in the standard order.
    private func getAllSharps(_ isNatural: Bool = false) -> [Pitch] {
        var sharps: [Pitch] = []
        let alter: Int = isNatural ? 0 : 1
        
        sharps.append(Pitch(step: .f, octave: 5, alter: alter))
        sharps.append(Pitch(step: .c, octave: 5, alter: alter))
        sharps.append(Pitch(step: .g, octave: 5, alter: alter))
        sharps.append(Pitch(step: .d, octave: 5, alter: alter))
        sharps.append(Pitch(step: .a, octave: 4, alter: alter))
        sharps.append(Pitch(step: .e, octave: 5, alter: alter))
        sharps.append(Pitch(step: .b, octave: 4, alter: alter))
        
        return sharps
    }
}
