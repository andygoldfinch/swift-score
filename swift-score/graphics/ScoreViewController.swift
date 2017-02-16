//
//  ScoreViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 16/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    @IBOutlet weak var scoreView: ScoreView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builder = ScoreBuilder()
        let parser = Parser()
        let score = builder.partwise(xml: parser.getDocument(withName: "example-simple")!)
        scoreView.drawScore(score: score)
        print("score drawn")
    }


}
