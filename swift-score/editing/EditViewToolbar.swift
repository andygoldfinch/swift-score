//
//  EditViewToolbar.swift
//  swift-score
//
//  Created by Andy Goldfinch on 21/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class EditViewToolbar: UIToolbar {
    /// Call the setup method on initialisation.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    /// Call the setup method on initialisation.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    /// Configure the toolbar.
    func setup() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.0
        self.clipsToBounds = true
    }
}
