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
    
    @IBOutlet weak var toolbarShowButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var scoreBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarTopConstraint: NSLayoutConstraint!
    
    var score: ScorePartwise!
    var scoreName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard score != nil else {
            print("Error: no score")
            return
        }
        
        self.title = scoreName
        scoreView.setScore(score: score)
        scoreView.delegate = self
        
        scrollView.contentSize = CGSize(width: scoreView.frame.width, height: scoreView.frame.height)
        
        toolbarShowPressed(self)
    }

    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        scoreView.changeSpacing(to: sender.value)
    }
    
    @IBAction func toolbarShowPressed(_ sender: Any) {
        toolbar.isHidden = !toolbar.isHidden
        let height = self.toolbar.frame.height
        
        if toolbar.isHidden {
            self.toolbarTopConstraint.constant -= height
            toolbarShowButton.image = #imageLiteral(resourceName: "ic_keyboard_arrow_down")
        }
        else {
            self.toolbarTopConstraint.constant += height
            toolbarShowButton.image = #imageLiteral(resourceName: "ic_keyboard_arrow_up")
        }
    }
    
}

extension MainViewController: ScoreViewDelegate {
    func heightWasSet(height: CGFloat) {
        self.scoreBottomConstraint.constant = height - self.scrollView.frame.height + 64
    }
    
    func widthWasSet(width: CGFloat) {
        self.scoreView.frame.size = CGSize(width: width, height: self.scrollView.frame.height)
        self.scoreTrailingConstraint.constant = width - self.scrollView.frame.width + 64
    }
    
    func keyboardDidHide() {
        scrollBottomConstraint.constant = 0
    }
    
    func keyboardDidShow(height: CGFloat) {
        scrollBottomConstraint.constant = height
    }
}

