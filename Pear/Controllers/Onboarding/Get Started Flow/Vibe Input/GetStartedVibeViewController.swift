//
//  GetStartedVibeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

struct FruitVibe {
    let image: UIImage
    let text: String
    let textColor: UIColor
}

class GetStartedVibeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    var gettingStartedProfileData: GettingStartedUserProfileData!
    var fruitVibes: [FruitVibe] = []
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedUserProfileData) -> GetStartedVibeViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedVibeViewController.self), bundle: nil)
        guard let interestsVC = storyboard.instantiateInitialViewController() as? GetStartedVibeViewController else { return nil }
        interestsVC.gettingStartedProfileData = gettingStartedData
        return interestsVC
    }
    
    func saveVibes() {
        
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        self.saveVibes()
        guard let shortBioVC = GetStartedShortBioViewController.instantiate(gettingStartedData: self.gettingStartedProfileData) else {
            print("Failed to create short Bio VC")
            return
        }
        self.navigationController?.pushViewController(shortBioVC, animated: true)
    }
    
}

// MARK: - Life Cycle
extension GetStartedVibeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.stylize()
    }
    
    func stylize() {
        self.nextButton.stylizeDark()
    }
    
    func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

// MARK: - Setup Fruit Vibes
extension GetStartedVibeViewController {
    
    func allFruitVibes() -> [FruitVibe] {
        var fruitVibes: [FruitVibe] = []
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-apple")!, text: "Forbidden Fruit",
                                    textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-coconut")!, text: "Coco-nuts",
                                    textColor: UIColor(red: 0.51, green: 0.33, blue: 0.35, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-avocado")!, text: "Extra Like Guac",
                                    textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-bananas")!, text: "BANANAS!",
                                    textColor: UIColor(red: 0.88, green: 0.72, blue: 0.04, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-cherry")!, text: "Cherry Bomb",
                                    textColor: UIColor(red: 0.67, green: 0.24, blue: 0.33, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-grapes")!, text: "Grapeful",
                                    textColor: UIColor(red: 0.35, green: 0.29, blue: 0.50, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-kiwi")!, text: "Klutzy Kiwi",
                                    textColor: UIColor(red: 0.64, green: 0.42, blue: 0.42, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-lemon")!, text: "Zesty",
                                    textColor: UIColor(red: 0.76, green: 0.66, blue: 0.09, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-pepper")!, text: "Spicy",
                                    textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-raddish")!, text: "Baddest Radish",
                                    textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-strawberry")!, text: "Fruity Cutie",
                                    textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-watermelon")!, text: "Just Add Water",
                                    textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
        
        return fruitVibes
    }
}

// MARK: - Collection View Delegate/Data Source
extension GetStartedVibeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fruitVibes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let fruitVibeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FruitVibeCollectionViewCell", for: indexPath) as? FruitVibeCollectionViewCell {
            let fruit = self.fruitVibes[indexPath.item]
            fruitVibeCell.imageView.image = fruit.image
            fruitVibeCell.imageView.contentMode = .scaleAspectFit
            fruitVibeCell.vibeLabel.text = fruit.text
            fruitVibeCell.vibeLabel.textColor = fruit.textColor
            fruitVibeCell.vibeLabel.font = UIFont(name: StylingConfig.displayFontMedium, size: 17)
            fruitVibeCell.vibeLabel.adjustsFontSizeToFitWidth = true
            fruitVibeCell.vibeLabel.textAlignment = .center
            return fruitVibeCell
        } else {
            return UICollectionViewCell()
        }
    }

}
