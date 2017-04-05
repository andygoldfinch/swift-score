//
//  MainTableViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 02/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit
import AEXML

fileprivate typealias MetaScore = (name: String, score: ScorePartwise)

class MainTableViewController: UITableViewController {
    let sections = ["Example Scores", "Custom Scores"]
    let exampleFiles: [String] = ["simple", "complex-1", "complex-2", "complex-3", "custom"]
    var files: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFileList()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    /// Return the number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return exampleFiles.count
        }
        else {
            return files.count
        }
    }
    
    
    /// Return the section name
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    
    /// Set the text for a specific cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! MainTableViewCell

        if indexPath.section == 0 {
            cell.labelName.text = exampleFiles[indexPath.row]
        }
        else {
            cell.labelName.text = files[indexPath.row]
        }

        return cell
    }
    
    
    /// Return whether a row can be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    
    /// Handle table view editing
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DocumentHandler().deleteDocument(name: files[indexPath.row])
            files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 
    @IBAction func addScorePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Create New Score", message: "Enter score name:", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak alert] (_) in
            let textField = alert!.textFields![0]
            self.createScore(name: textField.text ?? "")
        } )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createScore(name: String) {
        var processedName = name
        processedName = processedName.replacingOccurrences(of: " ", with: "")
        processedName = processedName.addXml()
        
        let score = ScorePartwise.defaultScore
        let documentHandler = DocumentHandler()
        let scoreWriter = ScoreWriter()
        let document = scoreWriter.makeDocument(score: score)
        documentHandler.saveDocument(document, name: processedName)
        
        self.performSegue(withIdentifier: "scoreSegue", sender: (name, score))
    }
    
    func loadFileList() {
        let documentHandler = DocumentHandler()
        files = documentHandler.getDocumentNames()
    }

    
    
 

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
        if let viewController = segue.destination as? MainViewController {
            let documentHandler = DocumentHandler()
            var name: String!
            var document: AEXMLDocument!
            var isExample: Bool = false
            
            if let cell = sender as? MainTableViewCell {
                name = cell.labelName.text! + ".xml"
                let indexPath = self.tableView.indexPath(for: cell)
                if indexPath!.section == 0 {
                    isExample = true
                }
            }
            else if let metaScore = sender as? MetaScore {
                viewController.scoreName = metaScore.name
                viewController.score = metaScore.score
                return
            }
            else {
                name = "simple.xml"
            }
            
            if isExample {
                document = documentHandler.getExampleDocument(name: name)
            }
            else {
                document = documentHandler.getDocument(name: name)
            }

            let scoreBuilder = ScoreBuilder()
            viewController.scoreName = name.removeXml()
            
            if let document = document {
                viewController.score = scoreBuilder.partwise(xml: document)
            }
        }
    }
 

}
