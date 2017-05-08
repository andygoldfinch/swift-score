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
    let exampleFiles: [String] = ["Simple", "Saltarello", "Mozart-Trio", "Custom"]
    var files: [String] = []
    
    
    /// Called whenever the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFileList()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.reloadData()
    }

    
    /// Return the number of sections in the table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    /// Return the number of rows in each section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return exampleFiles.count
        }
        else {
            return files.count
        }
    }
    
    
    /// Return the section name.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    
    /// Set the text for a specific cell.
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
    
    
    /// Return whether a row can be edited.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    
    /// Specifiy a custom delete button.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action: UITableViewRowAction = UITableViewRowAction(style: .default, title: "Delete", handler: delete)
        action.backgroundColor = UIColor(red: 168.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        return [action]
    }
    
    
    /// Delete an item at the given index path.
    func delete(action: UITableViewRowAction, itemAt indexPath: IndexPath) {
        DocumentHandler().deleteDocument(name: files[indexPath.row])
        files.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
 
    /// Called when the add score button is pressed.
    @IBAction func addScorePressed(_ sender: Any) {
        self.presentInputAlert(title: "Create New Score", message: "Enter score name:") {
            self.createScore(name: $0 ?? "")
        }
    }
    
    
    /// Create an empty score with the given name.
    func createScore(name: String) {
        var processedName = name
        processedName = processedName.replacingOccurrences(of: " ", with: "")
        processedName = processedName.addXml()
        
        let score = ScorePartwise.defaultScore
        let documentHandler = DocumentHandler()
        let scoreWriter = ScoreWriter()
        let document = scoreWriter.makeDocument(score: score)
        documentHandler.saveDocument(document, name: processedName)
        
        self.performSegue(withIdentifier: "scoreSegue", sender: (processedName.removeXml(), score))
    }
    
    
    /// Load the list of files using a DocumentHandler object.
    func loadFileList() {
        let documentHandler = DocumentHandler()
        files = documentHandler.getDocumentNames()
    }


    /// Prepare for a segue.
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

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!    
}
