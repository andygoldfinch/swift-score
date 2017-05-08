//
//  TutorialTableViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 10/04/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class TutorialTableViewController: UITableViewController {
    var delegate: TutorialTableDelegate?
    
    /// Called when the view is initially loaded.
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    /// Notify the delegate when a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.selected(row: indexPath.row)
        }
    }
}


protocol TutorialTableDelegate {
    func selected(row: Int)
}
