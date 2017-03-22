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
}
