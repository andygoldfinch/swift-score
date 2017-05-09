//
//  ScorePartwise.swift
//  swift-score
//
//  Created by Andy Goldfinch on 14/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

/// Representation of a partwise score.
struct ScorePartwise {
    var partList: [ScorePart]!
    var parts: [Part]!
}


/// Representation of a MusicXML ScorePart, containing the name and ID of a part.
struct ScorePart {
    var id: String!
    var partName: String!
}


/// Representation of a single part.
struct Part {
    var id: String!
    var measures: [Measure]!
}


/// Representation of a single measure.
struct Measure {
    var number: String!
    var attributes: Attributes?
    var notes: [Note]!
}


/// Representation of the attributes for a single measure.
struct Attributes {
    var divisions: Int?
    var key: Key?
    var time: Time?
    var clef: Clef?
}


/// Representation of a key.
struct Key {
    var fifths: Int!
}


/// Representation of a time signature.
struct Time {
    var beats: Int!
    var beatType: Int!
}


/// Representation of a clef.
struct Clef {
    var sign: String!
    var line: Int!
}


/// Representation of a single note.
struct Note {
    var chord: Bool!
    var pitch: Pitch?
    var duration: Int!
    var type: NoteType!
    var dots: Int!
    var isRest: Bool {
        return pitch == nil
    }
}


/// The possible types of notes, corresponding to the MusicXML specification.
enum NoteType: String {
    case n1024 = "1024th"
    case n512 = "512th"
    case n256 = "256th"
    case n128 = "128th"
    case n64 = "64th"
    case n32 = "32nd"
    case n16 = "16th"
    case n8 = "eighth"
    case n4 = "quarter"
    case n2 = "half"
    case n1 = "whole"
    case nx2 = "breve"
    case nx4 = "long"
    case nx8 = "maxima"
    case invalid = "invalid"
}


/// The pitch for a note.
struct Pitch {
    var step: PitchStep!
    var octave: Int!
    var alter: Int?
}


/// The possible values for the step of a note's pitch.
enum PitchStep: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"
    case g = "G"
}
