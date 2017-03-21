//
//  StringExtension.swift
//  swift-score
//
//  Created by Andy Goldfinch on 21/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation

extension String {
    func removeXml() -> String {
        return self.replacingOccurrences(of: ".xml", with: "")
    }
    
    func addXml() -> String {
        let string = self.removeXml()
        return string.appending(".xml")
    }
}
