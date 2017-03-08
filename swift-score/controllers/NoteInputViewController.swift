//
//  NoteInputViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 06/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class NoteInputViewController: UIViewController {
    var delegate: NoteInputDelegate? = nil
    
    // Length
    @IBOutlet weak var buttonSemibreve: UIButton!
    @IBOutlet weak var buttonMinim: UIButton!
    @IBOutlet weak var buttonCrotchet: UIButton!
    @IBOutlet weak var buttonQuaver: UIButton!
    @IBOutlet weak var buttonSemiquaver: UIButton!
    
    // Other
    @IBOutlet weak var buttonRest: UIButton!
    @IBOutlet weak var buttonChord: UIButton!
    
    // Pitches
    @IBOutlet weak var buttonC4: UIButton!
    @IBOutlet weak var buttonD4: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        let type: NoteInputType!
        
        switch sender {
        case buttonSemibreve:
            type = .length(.n1)
        case buttonMinim:
            type = .length(.n2)
        default:
            type = .other
            print("Unhandled button click")
        }
        
        if let delegate = delegate {
            delegate.selectedInput(inputType: type)
        }
    }
    
    @IBAction func closeTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.closeTapped()
        }
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

protocol NoteInputDelegate {
    func selectedInput(inputType: NoteInputType)
    func closeTapped()
}

enum NoteInputType {
    case length(NoteType)
    case accent
    case text
    case pitch(Pitch)
    case octave(Int)
    case other
}
