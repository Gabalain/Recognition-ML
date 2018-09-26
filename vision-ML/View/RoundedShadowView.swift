//
//  RoundedShadowView.swift
//  vision-ML
//
//  Created by Alain Gabellier on 26/09/2018.
//  Copyright © 2018 Alain Gabellier. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {
    
    override func awakeFromNib() {
        self.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1.0
        self.layer.opacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }
}

class RoundedShadowButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1.0
        self.layer.opacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }
}

class RoundedShadowImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1.0
        self.layer.opacity = 0.75
        self.layer.cornerRadius = 15
    }
}
