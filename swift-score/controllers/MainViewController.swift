//
//  MainViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 13/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var scoreView: ScoreView!
    
    var scoreName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = Parser()
        let builder = ScoreBuilder()
        
        print("Building partwise score")
        let score = builder.partwise(xml: parser.getDocument(withName: scoreName)!)
        
        scoreView.drawScore(score: score)
        
        print("score drawn")
    }

}
