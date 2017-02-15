//
//  MainViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 13/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = Parser()
        let builder = ScoreBuilder()
        
        print("Building partwise score")
        let score = builder.partwise(xml: parser.getDocument(withName: "example-complex")!)
        
        label.text = scoreToText(score: score)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scoreToText(score: ScorePartwise) -> String {
        var string = ""
        
        for part in score.parts {
            string.append("Part \(part.id ?? ""): ")
            
            for measure in part.measures {
                for note in measure.notes {
                    string.append(noteToText(note: note))
                    string.append(" ")
                }
                string.append("| ")
            }
            
            string.append("\n\n")
        }
        
        return string
    }
    
    
    func noteToText(note: Note) -> String {
        var n: String = ""
        if let pitch = note.pitch {
            
            n = "\(pitch.step.rawValue)\(pitch.octave ?? 0)\(alterToText(accidental: pitch.alter))"
        }
        else {
            n = "~"
        }
        
        var l: String = "!"
        if let temp = note.type {
            l = temp.rawValue
        }
        
        return "(\(n), \(l))"
    }
    
    
    func alterToText(accidental: Int?) -> String {
        if let a = accidental {
            if a > 0 {
                return "#"
            }
            else if a < 0 {
                return "b"
            }
        }
        return ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
