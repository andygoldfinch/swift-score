//
//  InputViewButton.swift
//  swift-score
//
//  Created by Andy Goldfinch on 08/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class InputViewButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var margin: CGFloat = 4
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = cornerRadius
        imageEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom:margin, right: margin)
        imageView?.contentMode = .scaleAspectFit
    }

}
