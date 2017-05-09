//
//  MeasureProcessor.swift
//  swift-score
//
//  Created by Andy Goldfinch on 28/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

class MeasureProcessor {
    /// Set the attributes on each measure to be independent of previous bars, 
    /// allowing bars to be reordered without breaking the attributes.
    func process(measures: [Measure]) -> [Measure] {
        var previousAttributes = Attributes.defaultAttributes
        var processedMeasures: [Measure] = []
        
        for measure in measures {
            var newMeasure = measure
            let newAttributes = update(previousAttributes: previousAttributes, newAttributes: measure.attributes)
            newMeasure.attributes = newAttributes
            previousAttributes = newAttributes
            
            processedMeasures.append(newMeasure)
        }
        
        return processedMeasures
    }
    
    
    /// Return an updated attributes object.
    func update(previousAttributes: Attributes, newAttributes: Attributes?) -> Attributes {
        guard let new = newAttributes else {
            return previousAttributes
        }
        
        var current = previousAttributes
        
        if new.clef != nil && new.clef != current.clef {
            current.clef = new.clef
        }
        
        if new.divisions != nil && new.divisions != current.divisions {
            current.divisions = new.divisions
        }
        
        if new.key != nil && new.key != current.key {
            current.key = new.key
        }
        
        if new.time != nil && new.time != current.time {
            current.time = new.time
        }
        
        return current
    }
}
