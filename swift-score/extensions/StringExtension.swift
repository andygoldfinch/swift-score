//
//  StringExtension.swift
//  swift-score
//
//  Created by Andy Goldfinch on 21/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

/// Add useful functions to manage file extensions.
extension String {
    /// Remove all occurrences of ".xml" from a string.
    func removeXml() -> String {
        return self.replacingOccurrences(of: ".xml", with: "")
    }
    
    
    /// Ensure that the string end in ".xml".
    func addXml() -> String {
        let string = self.removeXml()
        return string.appending(".xml")
    }
}
