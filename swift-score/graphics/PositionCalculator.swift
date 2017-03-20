//
//  PositionCalculator.swift
//  swift-score
//
//  Created by Andy Goldfinch on 03/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class PositionCalculator {
    let spacing: CGFloat
    let midY: CGFloat
    
    init(spacing: CGFloat, midY: CGFloat) {
        self.spacing = spacing
        self.midY = midY
    }


    /// Return the y position for the given note.
    func getNotePosition(note: Note, clef: Clef) -> (y: CGFloat, lines: LedgerLines?) {
        let octave = note.pitch?.octave ?? 0
        let stemUp: Bool = octave < 5 && note.type != .n1
        let noteOffset: CGFloat =  stemUp ? 3.5 * spacing : 0.5 * spacing
        let clefOffset: CGFloat = getClefOffset(clef: clef)
        var stepY: CGFloat!
        var lines: LedgerLines? = nil
        
        if let pitch = note.pitch {
            
            let step = pitch.step!
            
            switch step {
            case .c:
                stepY = midY + (3 * spacing) - noteOffset
            case .d:
                stepY = midY + (2.5 * spacing) - noteOffset
            case .e:
                stepY = midY + (2 * spacing) - noteOffset
            case .f:
                stepY = midY + (1.5 * spacing) - noteOffset
            case .g:
                stepY = midY + (1 * spacing) - noteOffset
            case .a:
                stepY = midY + (0.5 * spacing) - noteOffset
            default:
                stepY = midY - noteOffset
            }
            
            let octaveSpace = 3.5 * spacing
            let octave = pitch.octave - 4
            
            stepY = stepY - (CGFloat(octave) * octaveSpace)
            stepY = stepY + clefOffset
            
            if stepY < (midY - (2.5 * spacing) - noteOffset) {
                let numLines = Int((midY - stepY - noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: true)
            }
            else if stepY > (midY + (2.5 * spacing) - noteOffset) {
                let numLines = Int((stepY - midY + noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: false)
            }
            
            return (stepY, lines)
        }
        else {
            return (midY - 2 * spacing, nil)
        }
    }
    
    
    /// Return the y position for the given note.
    func getHeadPosition(note: Note, clef: Clef) -> (y: CGFloat, lines: LedgerLines?) {
        //let octave = previousNotes[0].pitch?.octave ?? 0
        let noteOffset: CGFloat = 0.5 * spacing
        let clefOffset: CGFloat = getClefOffset(clef: clef)
        var stepY: CGFloat!
        var lines: LedgerLines? = nil
        
        if let pitch = note.pitch {
            
            let step = pitch.step!
            
            switch step {
            case .c:
                stepY = midY + (3 * spacing) - noteOffset
            case .d:
                stepY = midY + (2.5 * spacing) - noteOffset
            case .e:
                stepY = midY + (2 * spacing) - noteOffset
            case .f:
                stepY = midY + (1.5 * spacing) - noteOffset
            case .g:
                stepY = midY + (1 * spacing) - noteOffset
            case .a:
                stepY = midY + (0.5 * spacing) - noteOffset
            default:
                stepY = midY - noteOffset
            }
            
            let octaveSpace = 3.5 * spacing
            let octave = pitch.octave - 4
            
            stepY = stepY - (CGFloat(octave) * octaveSpace)
            stepY = stepY + clefOffset
            
            if stepY < (midY - (2.5 * spacing) - noteOffset) {
                let numLines = Int((midY - stepY - noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: true)
            }
            else if stepY > (midY + (2.5 * spacing) - noteOffset) {
                let numLines = Int((stepY - midY + noteOffset) / spacing) - 2
                lines = LedgerLines(count: numLines, above: false)
            }
            
            return (stepY, lines)
        }
        else {
            return (midY - 2 * spacing, nil)
        }
    }
    
    
    /// Return the y position for the accidental for the given note.
    func getAccidentalPosition(note: Note, clef: Clef) -> CGFloat {
        guard let pitch = note.pitch else {
            return midY
        }
        guard let alter = pitch.alter else {
            return midY
        }
        
        let offset: CGFloat!
        let clefOffset = getClefOffset(clef: clef)
        var stepY: CGFloat!
        
        if alter >= 2 {
            offset = 0.5 * spacing
        }
        else if alter < 0 {
            offset = 1.7 * spacing
        }
        else {
            offset = 1.3 * spacing
        }
        
        let step = pitch.step!
        
        switch step {
        case .c:
            stepY = midY + (3 * spacing) - offset
        case .d:
            stepY = midY + (2.5 * spacing) - offset
        case .e:
            stepY = midY + (2 * spacing) - offset
        case .f:
            stepY = midY + (1.5 * spacing) - offset
        case .g:
            stepY = midY + (1 * spacing) - offset
        case .a:
            stepY = midY + (0.5 * spacing) - offset
        default:
            stepY = midY - offset
        }
        
        let octaveSpace = 3.5 * spacing
        let octave = pitch.octave - 4
        
        stepY = stepY - (CGFloat(octave) * octaveSpace)
        stepY = stepY + clefOffset
        
        return stepY
    }
    
    
    /// Calculate the Y position for the given clef
    func getClefPosition(clef: Clef) -> CGFloat {
        var typeOffset: CGFloat!
        
        switch clef.sign.lowercased() {
        case "g":
            typeOffset = (14 * spacing) / 11 + (3 * spacing)
        case "f":
            typeOffset = spacing
        default:
            typeOffset = 2 * spacing
        }
        
        let lineOffset: CGFloat = CGFloat(-(clef.line - 3)) * spacing
        
        return midY + lineOffset - typeOffset
    }
    
    
    /// Calculate the note offset in relation to the given clef
    func getClefOffset(clef: Clef) -> CGFloat {
        switch clef.sign.lowercased() {
        case "f":
            return (CGFloat(-clef.line) - 2.0) * spacing
        case "c":
            return CGFloat(-clef.line) * spacing
        default:
            return CGFloat(-(clef.line - 2)) * spacing
        }
    }
}


struct LedgerLines {
    let count: Int
    let above: Bool
    var below: Bool {
        return !above
    }
}
