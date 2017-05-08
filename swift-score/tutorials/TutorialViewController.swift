//
//  TutorialViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 10/04/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    @IBOutlet weak var containerViewTutorial: UIView!
    var tutorialTableViewController: TutorialTableViewController? {
        didSet {
            tutorialTableViewController?.delegate = self
        }
    }
    
    
    /// Load the appropriate view controller for the index.
    func loadViewController(index: Int) -> UIViewController? {
        let names: [String] = ["tutorialScoreManagement", "tutorialNoteInput", "tutorialRangeEditing", "tutorialNoteEditing"]
        
        return storyboard?.instantiateViewController(withIdentifier: names[index])
    }


    /// Prepare for a segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEmbedTable" {
            tutorialTableViewController = segue.destination as? TutorialTableViewController
        }
    }
}


extension TutorialViewController: TutorialTableDelegate {
    /// Called when a row of the table is selected.
    func selected(row: Int) {
        if let newViewController = loadViewController(index: row) {
            self.childViewControllers.forEach {$0.removeFromParentViewController()}
            self.addChildViewController(newViewController)
            
            newViewController.view!.frame = CGRect(origin: CGPoint.zero, size: containerViewTutorial.frame.size)
            
            containerViewTutorial.subviews.forEach {$0.removeFromSuperview()}
            containerViewTutorial.addSubview(newViewController.view!)
            containerViewTutorial.layoutSubviews()
        }
    }
}
