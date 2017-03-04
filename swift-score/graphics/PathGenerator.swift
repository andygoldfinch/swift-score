//
//  PathGenerator.swift
//  swift-score
//
//  Created by Andy Goldfinch on 04/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class PathGenerator {
    let spacing: CGFloat
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    /// Make a UIBezierPath representing the given ledger lines object.
    func makeLedgerLines(lines: LedgerLines?, type: NoteType, x: CGFloat, midY: CGFloat) -> UIBezierPath {
        if let ledger = lines {
            var y = ledger.above ? (midY -  3 * spacing) : (midY + 3 * spacing)
            let space = ledger.above ? -spacing : spacing
            let startX = x - 0.4 * spacing
            let length: CGFloat = type == .n1 ? 2.0 : 1.4
            let endX = x + length * spacing
            
            let path = UIBezierPath()
            
            for _ in 1...ledger.count {
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: endX, y: y))
                
                y += space
            }
            
            //path.stroke()
            return path
        }
        else {
            return UIBezierPath()
        }
    }
    
    
    /// Make a UIBezierPath representing dots for the given note, relative to the given note frame.
    func makeDots(note: Note, noteFrame: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        if note.dots > 0 {
            var x: CGFloat!
            if note.type == .n1 {
                x = noteFrame.maxX + 0.4 * spacing
            }
            else {
                x = noteFrame.minX + 1.4 * spacing
            }
            
            let y: CGFloat!
            if note.pitch == nil {
                y = noteFrame.minY + (4/3) * spacing
            }
            else if note.pitch!.octave >= 5 {
                y = noteFrame.minY + (2/3) * spacing
            }
            else {
                y = noteFrame.maxY - (1/3) * spacing
            }
            
            for _ in 1...note.dots {
                path.append(makeDot(x: x, y: y))
                x = x + 0.5 * spacing
            }
        }
        
        return path
    }
    
    
    /// Make a UIBezierPath representing dot at the given location.
    func makeDot(x: CGFloat, y: CGFloat) -> UIBezierPath {
        let frame = CGRect(x: x, y: y, width: spacing/4, height: spacing/4)
        let path = UIBezierPath(ovalIn: frame)
        //path.stroke()
        //path.fill()
        return path
    }
    
    
    /// Make a UIBezierPath representing a barline in the given place.
    func makeBarline(x: CGFloat, midY: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: midY - 2 * spacing))
        path.addLine(to: CGPoint(x: x, y: midY + 2 * spacing))
        //path.stroke()
        return path
    }
    
    
    /// Make a UIBezierPath representing the staff
    func makeStaff(midY: CGFloat, startX: CGFloat, endX: CGFloat) -> UIBezierPath {
        let ys: [CGFloat] = [midY - 2 * spacing,
                             midY - spacing,
                             midY,
                             midY + spacing,
                             midY + 2 * spacing]
        
        let linePath = UIBezierPath()
        
        for y in ys {
            linePath.move(to: CGPoint(x: startX, y: y))
            linePath.addLine(to: CGPoint(x: endX, y: y))
        }
        
        //linePath.stroke()
        return linePath
    }
}
