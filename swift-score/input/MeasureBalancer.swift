//
//  MeasureBalancer.swift
//  swift-score
//
//  Created by Andy Goldfinch on 12/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

class MeasureBalancer {
    let lengths: [NoteType: Double]
    
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
        let targetTotal = timeToTarget(time)
        var total: Double = 0.0
        
        for note in notes {
            if note.chord! {
                continue
            }
            
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
        }
        
        if total < targetTotal {
            return .under
        }
        else if total > targetTotal {
            return .over
        }
        else {
            return .correct
        }
    }
    
    func timeToTarget(_ time: Time) -> Double {
        return Double(time.beats) / Double(time.beatType)
    }
}

enum BalancedResult {
    case under
    case correct
    case over
}
