//
//  ViewControllerExtension.swift
//  swift-score
//
//  Created by Andy Goldfinch on 09/04/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Display an alert to take input, using the given title and message. Passes the contents of the text field to the given closure.
    func presentInputAlert(title: String, message: String, onPress closure: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak alert] (_) in
            let textField = alert!.textFields![0]
            closure(textField.text)
        } )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
}
