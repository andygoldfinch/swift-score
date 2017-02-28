//
//  ScorePartwiseBuilder.swift
//  swift-score
//
//  Created by Andy Goldfinch on 14/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation
import AEXML

class ScoreBuilder {
    
    func partwise(xml: AEXMLDocument) -> ScorePartwise {
        var score: ScorePartwise = ScorePartwise()
        
        let root = xml.root
        
        score.partList = makePartList(element: root["part-list"])
        
        var parts: [Part] = []
        for element in root["part"].all ?? [] {
            if let part = makePart(element: element) {
                parts.append(part)
            }
        }
        
        score.parts = parts
        
        return score
    }
    
    
    /// Take a <part-list> element and return a list of ScorePart objects
    private func makePartList(element: AEXMLElement) -> [ScorePart] {
        var partList: [ScorePart] = []
        let elements = element["score-part"].all
        
        print("elements: \(elements)")
        
        for item in elements ?? [] {
            var scorePart = ScorePart()
            
            scorePart.id = item.attributes["id"]
            scorePart.partName = item["part-name"].string
            
            partList.append(scorePart)
        }
        
        print("partList: \(partList)")
        
        return partList
    }
    
    
    /// Take a single <part> element and return a Part
    private func makePart(element: AEXMLElement) -> Part? {
        var part = Part()
        
        part.id = element.attributes["id"]
        
        let elements = element["measure"].all
        var measures: [Measure] = []
        
        for item in elements ?? [] {
            if let m = makeMeasure(element: item) {
                measures.append(m)
            }
        }
        
        part.measures = measures
        
        return part
    }
    
    
    /// Take a single <measure> element and return a Measure
    private func makeMeasure(element: AEXMLElement) -> Measure? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var measure = Measure()
        
        measure.number = element.attributes["number"]
        
        measure.attributes = makeAttributes(element: element["attributes"])
        
        let noteElements = element["note"].all
        var notes: [Note] = []
        
        for item in noteElements ?? [] {
            if let n = makeNote(element: item) {
                notes.append(n)
            }
        }
        
        measure.notes = notes
        
        return measure
    }
    
    
    /// Take a single <attributes> element and return an Attributes object
    private func makeAttributes(element: AEXMLElement) -> Attributes? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var attributes = Attributes()
        attributes.divisions = element["divisions"].int
        attributes.key = makeKey(element: element["key"])
        attributes.time = makeTime(element: element["time"])
        attributes.clef = makeClef(element: element["clef"])
        
        return attributes
    }
    
    
    /// Take a single <key> element and return a Key
    private func makeKey(element: AEXMLElement) -> Key? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var key = Key()
        key.fifths = element["fifths"].int
        
        return key
    }
    
    
    /// Take a single <time> element and return a Time
    private func makeTime(element: AEXMLElement) -> Time? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var time = Time()
        time.beats = element["beats"].int
        time.beatType = element["beat-type"].int
        
        return time
    }
    
    
    /// Take a single <clef> element and return a Clef
    private func makeClef(element: AEXMLElement) -> Clef? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var clef = Clef()
        clef.sign = element["sign"].string
        clef.line = element["line"].int
        
        return clef
    }
    
    
    /// Take a single <note> element and return a Note
    private func makeNote(element: AEXMLElement) -> Note? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var note = Note()
        note.chord = element["chord"].count != 0 ? true : false
        note.pitch = makePitch(element: element["pitch"])
        note.duration = element["duration"].int
        note.type = NoteType(rawValue: element["type"].string) ?? .invalid
        note.dots = element["dot"].count
        
        return note
    }
    
    
    /// Take a single <pitch> element and return a Pitch
    private func makePitch(element: AEXMLElement) -> Pitch? {
        guard !element.children.isEmpty else {
            return nil
        }
        
        var pitch = Pitch()
        pitch.step = PitchStep(rawValue: element["step"].string)
        pitch.octave = element["octave"].int
        pitch.alter = element["alter"].int
        
        if pitch.step == nil {
            return nil
        }
        else {        
            return pitch
        }
    }
}






