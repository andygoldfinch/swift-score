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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        print("Table view loaded")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.selected(row: indexPath.row)
        }
    }

}

protocol TutorialTableDelegate {
    func selected(row: Int)
}
