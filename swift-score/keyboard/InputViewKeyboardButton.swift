//
//  InputViewKeyboardButton.swift
//  swift-score
//
//  Created by Andy Goldfinch on 08/03/2017.
//  Copyright © 2017 Andy Goldfinch. All rights reserved.
//

import UIKit

class InputViewKeyboardButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var borderColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var isWhite: Bool = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        
        if isWhite {
            self.backgroundColor = UIColor.white
        }
        else {
            self.backgroundColor = UIColor.black
        }
    }

}
