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
