//
//  Parser.swift
//  swift-score
//
//  Created by Andy Goldfinch on 13/02/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import Foundation
import AEXML

public class DocumentHandler {
    func getDocument(withName name: String) -> AEXMLDocument? {
                
        if let xmlPath = Bundle.main.path(forResource: name, ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) {
            
            let xmlDoc: AEXMLDocument? = try? AEXMLDocument(xml: data)        
            return xmlDoc
        }
        else {
            return nil
        }
    }
}
