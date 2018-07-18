//
//  Extensions.swift
//  TVShows
//
//  Created by Infinum Student Academy on 17/07/2018.
//  Copyright © 2018 Jakov Vidak. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setBottomBorder() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
}