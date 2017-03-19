//
//  ScoreWriter.swift
//  swift-score
//
//  Created by Andy Goldfinch on 17/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation
import AEXML

class ScoreWriter {
   
    /// Convert a ScorPartwise into an AEXMLDocument
    func makeDocument(score: ScorePartwise) -> AEXMLDocument {
        let doc = AEXMLDocument()
        
        let attributes = ["version": "3.0"]
        let scorePartwise = doc.addChild(name: "score-partwise", attributes: attributes)
        scorePartwise.addChild(makePartList(score.partList))
        
        for part in score.parts {
            scorePartwise.addChild(makePart(part))
        }
        
        return doc
    }
    
    
    /// Take a [ScorePart] and return a <part-list> element
    private func makePartList(_ partList: [ScorePart]) -> AEXMLElement {
        let element = AEXMLElement(name: "part-list")
        
        for part in partList {
            element.addChild(makeScorePart(part))
        }
        
        return element
    }
    
    
    /// Take a ScorePart and return a <socre-part> element
    func makeScorePart(_ part: ScorePart) -> AEXMLElement {
        let element = AEXMLElement(name: "score-part")
        
        element.attributes = ["id": part.id]
        element.addChild(name: "part-name", value: part.partName)
        
        return element
    }
    
    
    /// Take a Part and return a <part> element
    private func makePart(_ part: Part) -> AEXMLElement {
        let element = AEXMLElement(name: "part")
        
        element.attributes = ["id": part.id]
        
        for measure in part.measures {
            element.addChild(makeMeasure(measure))
        }
        
        return element
    }
    
    
    /// Take a Measure and return a <measure> element
    private func makeMeasure(_ measure: Measure) -> AEXMLElement {
        let element = AEXMLElement(name: "measure")
        
        element.attributes = ["number": measure.number]
        
        if let attributesElement = makeAttributes(measure.attributes) {
            element.addChild(attributesElement)
        }
        
        for note in measure.notes {
            element.addChild(makeNote(note))
        }
        
        return element
    }
    
    
    /// Take an Attributes and return an <attributes> element
    private func makeAttributes(_ attributes: Attributes?) -> AEXMLElement? {
        guard let attributes = attributes else {
            return nil
        }
        
        let element = AEXMLElement(name: "attributes")
        
        if let divisions = attributes.divisions {
            element.addChild(name: "divisions", value: String(divisions))
        }
        
        if let key = attributes.key {
            let keyElement = element.addChild(name: "key")
            keyElement.addChild(name: "fifths", value: String(key.fifths))
        }
        
        if let time = attributes.time {
            let timeElement = element.addChild(name: "time")
            timeElement.addChild(name: "beats", value: String(time.beats))
            timeElement.addChild(name: "beat-type", value: String(time.beatType))
        }
        
        if let clef = attributes.clef {
            let clefElement = element.addChild(name: "clef")
            clefElement.addChild(name: "sign", value: clef.sign)
            clefElement.addChild(name: "line", value: String(clef.line))
        }
        
        if element.children.count == 0 {
            return nil
        }
        else {
            return element
        }
    }
    
    
    /// Take a Note and return a <note> element
    private func makeNote(_ note: Note) -> AEXMLElement {
        let element = AEXMLElement(name: "note")
        
        if note.chord! {
            element.addChild(name: "chord")
        }
        
        if note.type != .invalid {
            element.addChild(name: "type", value: note.type.rawValue)
        }
        
        if let pitch = note.pitch {
            element.addChild(makePitch(pitch))
        }
        
        for _ in 0..<note.dots {
            element.addChild(name: "dot")
        }
        
        element.addChild(name: "duration", value: String(note.duration))
        
        return element
    }
    
    
    /// Take a Pitch and return a <pitch> element
    private func makePitch(_ pitch: Pitch) -> AEXMLElement {
        let element = AEXMLElement(name: "pitch")
        
        element.addChild(name: "step", value: pitch.step.rawValue)
        element.addChild(name: "octave", value: String(pitch.octave))
        
        if let alter = pitch.alter {
            element.addChild(name: "alter", value: String(alter))
        }
        
        return element
    }
}


