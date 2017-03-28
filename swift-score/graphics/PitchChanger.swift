//
//  PitchChanger.swift
//  swift-score
//
//  Created by Andy Goldfinch on 28/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

class PitchChanger {
    
    /// Change the pitch of the notes in the given measures by the given amount of steps.
    func change(measures: [Measure], steps: Int) -> [Measure] {
        var measures = measures
        
        for i in 0..<measures.count {
            for j in 0..<measures[i].notes.count {
                if measures[i].notes[j].pitch != nil {
                    measures[i].notes[j].pitch = change(pitch: measures[i].notes[j].pitch!, steps: steps)
                }
            }
        }
        
        return measures
    }
    
    
    /// Change a given pitch by the given amount of steps.
    func change(pitch: Pitch, steps: Int) -> Pitch {
        let pitches: [PitchStep] = [.c, .d, .e, .f, .g, .a, .b]
        
        let initialIndex = pitches.index(of: pitch.step)!
        let shiftedIndex = initialIndex + steps
        let newIndex = index(from: shiftedIndex)
        
        let newStep = pitches[newIndex]
        var newOctave = pitch.octave + octaveOffset(forIndex: shiftedIndex)
        newOctave = newOctave > 7 ? 7 : newOctave
        newOctave = newOctave < 1 ? 1 : newOctave
        
        return Pitch(step: newStep, octave: newOctave, alter: pitch.alter)
    }
    
    
    /// Calculate the octave difference from a shifted index number.
    private func octaveOffset(forIndex index: Int) -> Int {
        var octave = 0
        var index = index
        
        while index >= 7 {
            index -= 7
            octave += 1
        }
        
        while index < 0 {
            index += 7
            octave -= 1
        }
        
        return octave
    }
    
    
    /// Convert a shifted index to an index suitable for an array.
    private func index(from index: Int) -> Int {
        var index = index
        
        if index >= 0 {
            return index % 7
        }
        else {
            while index < 0 {
                index += 7
            }
        }
        
        return index
    }
}

