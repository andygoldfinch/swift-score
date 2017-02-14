//
//  MainViewController.swift
//  swift-score
//
//  Created by Andy Goldfinch on 13/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = Parser()
        
        print(parser.getDocument(withName: "example-simple")?.root["part"]["measure"]["attributes"])
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

}
