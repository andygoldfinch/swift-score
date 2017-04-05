//
//  MeasureBalancer.swift
//  swift-score
//
//  Created by Andy Goldfinch on 12/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

class MeasureBalancer {
    private let lengths: [NoteType: Double]
    private let types: [NoteType] = [.n1024, .n512, .n256, .n128, .n64, .n32, .n16, .n8, .n4, .n2, .n1, .nx2, .nx4, .nx8]
    
    init() {
        var dict: [NoteType: Double] = [:]
        
        dict[.n1024] = 1/1024
        dict[.n512]  = 1/512
        dict[.n256]  = 1/256
        dict[.n128]  = 1/128
        dict[.n64]   = 1/64
        dict[.n32]   = 1/32
        dict[.n16]   = 1/16
        dict[.n8]    = 1/8
        dict[.n4]    = 1/4
        dict[.n2]    = 1/2
        dict[.n1]    = 1
        dict[.nx2]   = 2
        dict[.nx4]   = 4
        dict[.nx8]   = 8
        
        dict[.invalid] = 0
        
        lengths = dict
    }
    
    
    /// Does a given list of notes fill a bar with the given time signature?
    func isBalanced(notes: [Note], time: Time) -> BalancedResult {
        return balance(notes: notes, time: time).balancedResult
    }
    
    
    /// Calculate the balancing of a bar, giving a BalancedResult and the remaining space in terms of the internal note measure.
    private func balance(notes: [Note], time: Time) -> (balancedResult: BalancedResult, remainingSpace: Double) {
        let targetTotal = timeToTarget(time)
        var total: Double = 0.0
        
        for note in notes {
            if note.chord! {
                continue
            }
            
            total += length(of: note)
        }
        
        let remainingSpace = targetTotal - total
        
        if total < targetTotal {
            return (.under, remainingSpace)
        }
        else if total > targetTotal {
            return (.over, remainingSpace)
        }
        else {
            return (.correct, remainingSpace)
        }

    }
    
    
    /// Return the length of a given note, in terms of the internal note measure.
    private func length(of note: Note) -> Double {
        var total: Double = 0.0
        let length = lengths[note.type]!
        total += length
        
        var dotTotal = 0.0
        var dotLength = 1.0
        for _ in 0..<note.dots {
            dotLength /= 2
            dotTotal += dotLength
        }
        
        if dotTotal > 0 {
            total += dotTotal * length
        }
        
        return total
    }
    
    
    /// Return the largest note that can fit in the given length (may leave space after the note). This method will check a maximum of 2 dots.
    private func note(within length: Double) -> Note {
        var note = Note()
        note.type = types.first!
        var previousNote = note
        
        for type in types {
            previousNote = note
            note.type = type
            note.dots = 0
            var newLength = self.length(of: note)
            if  newLength > length {
                return previousNote
            }
            else if newLength == length {
                return note
            }
            
            previousNote = note
            note.dots = 1
            newLength  = self.length(of: note)
            if  newLength > length {
                return previousNote
            }
            else if newLength == length {
                return note
            }
            
            previousNote = note
            note.dots = 2
            newLength  = self.length(of: note)
            if  newLength > length {
                return previousNote
            }
            else if newLength == length {
                return note
            }
        }
        
        return note
    }
    
    
    /// Convert a time object into a target length, in terms of the internal note measure.
    func timeToTarget(_ time: Time) -> Double {
        return Double(time.beats) / Double(time.beatType)
    }
    
    
    /// Can a given be note added to the list of notes in the given time signature?
    func canAdd(note: Note, to notes: [Note], time: Time) -> Bool {
        var newNotes = notes
        newNotes.append(note)
        
        return isBalanced(notes: newNotes, time: time) != .over
    }
    
    
    /// Split a note that won't fit into the end of a bar across two new lists of notes.
    func split(note: Note, in notes: [Note], time: Time) -> (first: [Note], second: [Note]) {
        var firstTotal = self.balance(notes: notes, time: time).remainingSpace
        
        var firstNotes: [Note] = []
        while firstTotal > 0 {
            let generatedNote = self.note(within: firstTotal)
            var insertedNote = note
            insertedNote.type = generatedNote.type
            insertedNote.dots = generatedNote.dots
            firstNotes.append(insertedNote)
            
            firstTotal -= length(of: insertedNote)
        }
        firstNotes.reverse()
        firstNotes = notes + firstNotes
        
        var newNotes = notes
        newNotes.append(note)
        var secondTotal = -self.balance(notes: newNotes, time: time).remainingSpace
        var secondNotes: [Note] = []
        while secondTotal > 0 {
            let generatedNote = self.note(within: secondTotal)
            var insertedNote = note
            insertedNote.type = generatedNote.type
            insertedNote.dots = generatedNote.dots
            secondNotes.append(insertedNote)
            secondTotal -= length(of: insertedNote)
        }
        
        return (firstNotes, secondNotes)
    }
}


enum BalancedResult {
    case under
    case correct
    case over
}
