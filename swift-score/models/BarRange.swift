//
//  BarRange.swift
//  swift-score
//
//  Created by Andy Goldfinch on 22/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

/// A representation of a range of bars, including the start and end bar.
struct BarRange {
    let start: Int
    let end: Int
    var count: Int {
        return (end - start) + 1
    }
    var isSingleBar: Bool {
        return count == 1
    }
    
    init(start: Int, end: Int) {
        var start = start
        var end = end
        
        if start < 0 {
            start = 0
        }
        
        if end < start {
            end = start
        }
        
        self.start = start
        self.end = end
    }
    
    func toString() -> String {
        if start == end {
            return "Bar \(start + 1)"
        }
        
        return "Bar \(start + 1) to Bar \(end + 1)"
    }
}


/// Conform to the Equatable protocol to allow comparison.
extension BarRange: Equatable {
    static func ==(lhs: BarRange, rhs: BarRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}


/// Representation of the location of a sinle selected note.
struct SelectedNote {
    var relativeBar: Int
    let note: Int
    let range: BarRange
    
    var absoluteBar: Int {
        get {
            return range.start + relativeBar
        }
        set {
            relativeBar = absoluteBar - range.start
        }
    }
}
