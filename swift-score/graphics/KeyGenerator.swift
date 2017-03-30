//
//  KeyBuilder.swift
//  swift-score
//
//  Created by Andy Goldfinch on 28/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

/// A class to build lists of notes in certain keys, for the purpose of displaying key signatures.
class KeyGenerator {
    
    /// Generate a list of notes in the key represented by the given fifths value.
    func makeKey(fifths: Int, clef: Clef) -> [Note] {
        let key = fifths > 0 ? getAllSharps(clef: clef)[0..<fifths] : getAllFlats(clef: clef)[0..<(-fifths)]
        var notes: [Note] = []
        
        for item in key {
            notes.append(Note(chord: false, pitch: item, duration: 0, type: .invalid, dots: 0))
        }
        
        return notes
    }
    
    
    /// Generate a list of naturals for use before the displaying of a new key.
    func makeNaturals(oldFifths: Int, newFifths: Int, clef: Clef) -> [Note] {
        var new: Int = newFifths
        if oldFifths > 0 && new < 0 {
            new = 0
        }
        else if oldFifths < 0 && new > 0 {
            new = 0
        }
        
        new = abs(new)
        
        let key = oldFifths > 0 ? getAllSharps(true, clef: clef)[new..<oldFifths] : getAllFlats(true, clef: clef)[new..<(-oldFifths)]
        var notes: [Note] = []
        
        for item in key {
            notes.append(Note(chord: false, pitch: item, duration: 0, type: .invalid, dots: 0))
        }
        
        return notes
    }
    
    
    /// Return a list of the pitches of all flats, in the standard order.
    private func getAllFlats(_ isNatural: Bool = false, clef: Clef? = nil) -> [Pitch] {
        var flats: [Pitch] = []
        let alter: Int = isNatural ? 0 : -1
        
        if clef == nil || clef!.sign.lowercased() == "g" {
            flats.append(Pitch(step: .b, octave: 4, alter: alter))
            flats.append(Pitch(step: .e, octave: 5, alter: alter))
            flats.append(Pitch(step: .a, octave: 4, alter: alter))
            flats.append(Pitch(step: .d, octave: 5, alter: alter))
            flats.append(Pitch(step: .g, octave: 4, alter: alter))
            flats.append(Pitch(step: .c, octave: 5, alter: alter))
            flats.append(Pitch(step: .f, octave: 4, alter: alter))
        }
        else if clef!.sign.lowercased() == "c" {
            flats.append(Pitch(step: .b, octave: 3, alter: alter))
            flats.append(Pitch(step: .e, octave: 4, alter: alter))
            flats.append(Pitch(step: .a, octave: 3, alter: alter))
            flats.append(Pitch(step: .d, octave: 4, alter: alter))
            flats.append(Pitch(step: .g, octave: 3, alter: alter))
            flats.append(Pitch(step: .c, octave: 4, alter: alter))
            flats.append(Pitch(step: .f, octave: 3, alter: alter))
        }
        else {
            flats.append(Pitch(step: .b, octave: 2, alter: alter))
            flats.append(Pitch(step: .e, octave: 3, alter: alter))
            flats.append(Pitch(step: .a, octave: 2, alter: alter))
            flats.append(Pitch(step: .d, octave: 3, alter: alter))
            flats.append(Pitch(step: .g, octave: 2, alter: alter))
            flats.append(Pitch(step: .c, octave: 3, alter: alter))
            flats.append(Pitch(step: .f, octave: 2, alter: alter))
        }
        
        return flats
    }
    
    
    /// Return a list of the pitches of all sharps, in the standard order.
    private func getAllSharps(_ isNatural: Bool = false, clef: Clef? = nil) -> [Pitch] {
        var sharps: [Pitch] = []
        let alter: Int = isNatural ? 0 : 1
        
        if clef == nil || clef!.sign.lowercased() == "g" {
            sharps.append(Pitch(step: .f, octave: 5, alter: alter))
            sharps.append(Pitch(step: .c, octave: 5, alter: alter))
            sharps.append(Pitch(step: .g, octave: 5, alter: alter))
            sharps.append(Pitch(step: .d, octave: 5, alter: alter))
            sharps.append(Pitch(step: .a, octave: 4, alter: alter))
            sharps.append(Pitch(step: .e, octave: 5, alter: alter))
            sharps.append(Pitch(step: .b, octave: 4, alter: alter))
        }
        else if clef!.sign.lowercased() == "c" {
            sharps.append(Pitch(step: .f, octave: 4, alter: alter))
            sharps.append(Pitch(step: .c, octave: 4, alter: alter))
            sharps.append(Pitch(step: .g, octave: 4, alter: alter))
            sharps.append(Pitch(step: .d, octave: 4, alter: alter))
            sharps.append(Pitch(step: .a, octave: 3, alter: alter))
            sharps.append(Pitch(step: .e, octave: 4, alter: alter))
            sharps.append(Pitch(step: .b, octave: 3, alter: alter))
        }
        else {
            sharps.append(Pitch(step: .f, octave: 3, alter: alter))
            sharps.append(Pitch(step: .c, octave: 3, alter: alter))
            sharps.append(Pitch(step: .g, octave: 3, alter: alter))
            sharps.append(Pitch(step: .d, octave: 3, alter: alter))
            sharps.append(Pitch(step: .a, octave: 2, alter: alter))
            sharps.append(Pitch(step: .e, octave: 3, alter: alter))
            sharps.append(Pitch(step: .b, octave: 2, alter: alter))
        }
        
        return sharps
    }
}
