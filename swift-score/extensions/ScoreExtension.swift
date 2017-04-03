//
//  ScoreExtension.swift
//  swift-score
//
//  Created by Andy Goldfinch on 28/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation


extension Clef: Equatable {
    static func ==(lhs: Clef, rhs: Clef) -> Bool {
        return lhs.line == rhs.line
            && lhs.sign == rhs.sign
    }
}


extension Key: Equatable {
    static func ==(lhs: Key, rhs: Key) -> Bool {
        return lhs.fifths == rhs.fifths
    }
}


extension Time: Equatable {
    static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.beats == rhs.beats
            && lhs.beatType == rhs.beatType
    }
}

extension Attributes: Equatable {
    static func ==(lhs: Attributes, rhs: Attributes) -> Bool {
        return lhs.clef == rhs.clef
            && lhs.divisions == rhs.divisions
            && lhs.key == rhs.key
            && lhs.time == rhs.time
    }
}

extension Attributes {
    static var defaultAttributes: Attributes {
        var attributes = Attributes()
        attributes.divisions = 8
        attributes.clef = Clef(sign: "G", line: 2)
        attributes.key = Key(fifths: 0)
        attributes.time = Time(beats: 4, beatType: 4)
        
        return attributes
    }
}

extension Measure {
    static var defaultMeasure: Measure {
        var measure = Measure()
        measure.number = "1"
        measure.notes = []
        measure.attributes = Attributes.defaultAttributes
        
        return measure
    }
}

extension ScorePartwise {
    static var defaultScore: ScorePartwise {
        var score = ScorePartwise()
        score.partList = [ScorePart(id: "1", partName: "part-1")]
        score.parts = [Part(id: "1", measures: [Measure.defaultMeasure])]
        
        return score
    }
}

extension Pitch: CustomStringConvertible {
    var description: String {
        return "\(step.rawValue)\(octave ?? 4)\(alterToString(alter ?? 0))"
    }
    
    private func alterToString(_ alter: Int) -> String {
        switch alter {
        case -2:
            return "♭♭"
        case -1:
            return "♭"
        case 1:
            return "♯"
        case 2:
            return "♯♯"
        default:
            return ""
        }
    }
}

extension NoteType: CustomStringConvertible {
    var description: String {
        switch self {
        case .n1:
            return "Semibreve"
        case .n2:
            return "Minim"
        case .n4:
            return "Crotchet"
        case .n8:
            return "Quaver"
        case .n16:
            return "Semiquaver"
        default:
            return self.rawValue
        }
    }
}


