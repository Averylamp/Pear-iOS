//
//  FruitVibeCollectionViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class FruitVibeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var vibeLabel: UILabel!
    
    func setSelected(selected: Bool) {
        if selected {
            self.layer.borderColor = Colors.brandPrimaryLight.cgColor
            self.backgroundColor = Colors.brandPrimaryLight.withAlphaComponent(0.4)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowColor = Colors.shadowColor.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.vibeLabel.font = UIFont(name: StylingConfig.displayFontBold, size: 17)
        } else {
            self.layer.shadowOpacity = 0.0
            self.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.00).cgColor
            self.vibeLabel.font = UIFont(name: StylingConfig.displayFontMedium, size: 17)
        }
    }
    
    func setFruitVibe(fruit: FruitVibe) {
        self.backgroundColor = UIColor.white
        self.imageView.image = fruit.image
        self.imageView.contentMode = .scaleAspectFit
        self.vibeLabel.text = fruit.text
        self.vibeLabel.textColor = fruit.textColor
        self.vibeLabel.adjustsFontSizeToFitWidth = true
        self.vibeLabel.textAlignment = .center
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
    }
    
}
