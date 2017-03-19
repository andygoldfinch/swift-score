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
    
    /// Retrieve an xml document from the examples folder.
    func getExampleDocument(name: String) -> AEXMLDocument? {
                
        if let xmlPath = Bundle.main.path(forResource: name, ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) {
            
            let xmlDoc: AEXMLDocument? = try? AEXMLDocument(xml: data)        
            return xmlDoc
        }
        else {
            return nil
        }
    }
    
    
    /// Retrieve an xml document from the document directory.
    func getDocument(name: String) -> AEXMLDocument? {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: directory.appendingPathComponent(name)) {
            
            let xmlDoc: AEXMLDocument? = try? AEXMLDocument(xml: data)
            if xmlDoc?.xml == nil {
                return nil
            }
            return xmlDoc
        }
        else {
            return nil
        }
    }
    
    
    /// Save a document to the document directory.
    func saveDocument(_ document: AEXMLDocument, name: String) {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = directory.appendingPathComponent(name)
            
            do {
                try document.xml.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                print("Error writing file")
            }
        }
    }
    
    
    /// Retrieve a list of document names in the document directory.
    func getDocumentNames() -> [String] {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                var names = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
                
                names = names.filter {
                    $0.pathExtension == "xml"
                }
                
                return names.map {
                    $0.deletingPathExtension().lastPathComponent
                }
            }
            catch {
                print("Error reading files")
                return []
            }
        }
        else {
            return []
        }
    }
}
