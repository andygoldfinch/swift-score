//
//  MainTableViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 02/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    var files: [String] = ["simple", "complex-1", "complex-2", "complex-3", "custom"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentHandler = DocumentHandler()
        let userFiles = documentHandler.getDocumentNames()
        files.append(contentsOf: userFiles)
        
        /*let documentHandler = DocumentHandler()
        let builder = ScoreBuilder()
        let score = builder.partwise(xml: documentHandler.getExampleDocument(name: files[0])!)
        
        print("Saving score")
        let document = ScoreWriter().makeDocument(score: score)
        documentHandler.saveDocument(document, name: "test-1.xml")
        print("Document saved")
        
        print("Document fetched: ")
        print(documentHandler.getDocument(name: "test-1.xml")?.xmlCompact)*/

        // Uncomment for edit button
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// Return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! MainTableViewCell

        cell.labelName.text = files[indexPath.row]

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MainViewController, let cell = sender as? MainTableViewCell {
            let documentHandler = DocumentHandler()
            let document = documentHandler.getDocument(name: cell.labelName.text! + ".xml")
            let scoreBuilder = ScoreBuilder()
            viewController.scoreName = cell.labelName.text!
            if let document = document {
                viewController.score = scoreBuilder.partwise(xml: document)
            }
            else {
                let exampleDocument = documentHandler.getExampleDocument(name: cell.labelName.text!)
                if let exampleDocument = exampleDocument {
                    viewController.score = scoreBuilder.partwise(xml: exampleDocument)
                }
            }
        }
    }
 

}
