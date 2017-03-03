//
//  ImageViewGenerator.swift
//  swift-score
//
//  Created by Andy Goldfinch on 03/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewGenerator {
    let spacing: CGFloat
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    /// Return an image representing the given note.
    func makeNoteView(note: Note, x: CGFloat, y: CGFloat) -> UIImageView {
        let view = UIImageView()
        let isSemibreve: Bool = note.type == .n1 && !note.isRest
        let height: CGFloat = isSemibreve ? spacing : 4 * spacing
        view.frame = CGRect(x: x, y: y, width: 3*spacing, height: height)
        
        if let image = getNoteImage(for: note) {
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)
            view.frame = CGRect(x: x, y: y, width: rect.width, height: height)
            view.image = image
            view.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        return view
    }
    
    
    /// Return an image view representing the accidental for the given note.
    func makeAccidentalView(note: Note, x: CGFloat, y: CGFloat) -> UIImageView {
        guard let alter = note.pitch?.alter else {
            return UIImageView()
        }
        
        let view = UIImageView()
        let height: CGFloat!
        
        if alter <  0 {
            height = 2.4 * spacing
        }
        else if alter < 2 {
            height = 2.6 * spacing
        }
        else {
            height = spacing
        }
        
        view.frame = CGRect(x: x, y: y, width: 2 * spacing, height: height)
        
        if let image = getAccidentalImage(alter: alter) {
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)
            view.frame = CGRect(x: x, y: y, width: rect.width, height: height)
            view.image = image
            view.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        return view
    }
    
    
    /// Return an image view representing the given clef
    func makeClefView(clef: Clef, x: CGFloat, y: CGFloat) -> UIImageView {
        let view = UIImageView()
        let height = getClefHeight(clef: clef)
        
        view.frame = CGRect(x: x, y: y, width: 3 * spacing, height: height)
        
        if let image = getClefImage(clef: clef) {
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)
            view.frame = CGRect(x: x, y: y, width: rect.width, height: height)
            view.image = image
            view.contentMode = .scaleAspectFit
        }
        
        return view
    }


    /// Calculate the height for the given clef
    private func getClefHeight(clef: Clef) -> CGFloat {
        switch clef.sign.lowercased() {
        case "g":
            return (75 * spacing) / 11
        case "f":
            return 3.25 * spacing
        default:
            return 4 * spacing
        }
    }


    /// Return an image for the given note
    private func getNoteImage(for note: Note) -> UIImage? {
        var name: String!
        if let type = note.type {
            switch type {
            case .n16:
                name = "semiquaver"
            case .n8:
                name = "quaver"
            case .n4:
                name = "crotchet"
            case .n2:
                name = "minim"
            case .n1:
                name = "semibreve"
            default:
                name = "crotchet"
            }
            
            
            if let pitch = note.pitch {
                if pitch.octave >= 5 {
                    name.append("-down")
                }
                else {
                    name.append("-up")
                }
            }
            else {
                name.append("-rest")
            }
            
            return UIImage(named: name)
        }
        else {
            return nil
        }
    }
    
    
    /// Return an image for the accidental of the given note.
    private func getAccidentalImage(alter: Int) -> UIImage? {
        switch alter {
        case -2:
            return UIImage(named: "flat-double")
        case -1:
            return UIImage(named: "flat")
        case 1:
            return UIImage(named: "sharp")
        case 2:
            return UIImage(named: "sharp-double")
        default:
            return UIImage(named: "natural")
        }
    }
    
    
    /// Return an image of the given clef.
    private func getClefImage(clef: Clef) -> UIImage? {
        let name: String = "clef-" + clef.sign.lowercased()
        
        return UIImage(named: name)
    }
}
