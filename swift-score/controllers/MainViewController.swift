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
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scoreBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreLeadingConstraint: NSLayoutConstraint!
    
    var scoreName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreView.heightClosure = {
            self.scoreBottomConstraint.constant = $0 - self.scrollView.frame.height + 64
        }
        
        scoreView.widthClosure = {
            self.scoreTrailingConstraint.constant = $0 - self.scrollView.frame.width + 64
        }

        let parser = Parser()
        let builder = ScoreBuilder()
        //scrollView.contentSize = CGSize(width: scoreView.frame.width, height: scoreView.frame.height)

        
        print("Building partwise score")
        let score = builder.partwise(xml: parser.getDocument(withName: scoreName)!)
        
        scoreView.drawScore(score: score)
        
        print("score drawn")
    }

}

