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
    @IBInspectable var margin: CGFloat = 6
    
    var isToggled: Bool = false {
        didSet {
            if isToggled {
                backgroundColor = UIColor(white: 0.88, alpha: 1.0)
            }
            else {
                backgroundColor = UIColor.white
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = cornerRadius
        imageEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom:margin, right: margin)
        imageView?.contentMode = .scaleAspectFit
    }

    func toggle() {
        isToggled = !isToggled
    }
}
