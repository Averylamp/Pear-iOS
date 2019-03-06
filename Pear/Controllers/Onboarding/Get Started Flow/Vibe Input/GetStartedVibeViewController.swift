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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    let pageNumber: CGFloat = 4.0
    
    let betweenVibeSpacing: CGFloat = 12
    var selectedItems: [IndexPath] = []
    
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
        self.gettingStartedProfileData.profileVibes = []
        for indexPath in self.selectedItems {
            let fruitVibe = self.fruitVibes[indexPath.item]
            self.gettingStartedProfileData.profileVibes.append(fruitVibe.text.lowercased())
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        self.saveVibes()
        if self.gettingStartedProfileData.profileVibes.count == 0 {
            self.alert(title: "Missing Vibe", message: "Your friend is missing their vibes!  Please choose one!")
            return
        }
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
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
        self.nextButton.stylizeDark()
        self.progressWidthConstraint.constant = (pageNumber - 1) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
        UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func setupCollectionView() {
        self.fruitVibes = self.allFruitVibes()
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

// MARK: - Setup Fruit Vibes
extension GetStartedVibeViewController {
    
    func allFruitVibes() -> [FruitVibe] {
        var fruitVibes: [FruitVibe] = []
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-apple")!,
                                    text: "Forbidden Fruit",
                                    textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-coconut")!,
                                    text: "Coco-nuts",
                                    textColor: UIColor(red: 0.51, green: 0.33, blue: 0.35, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-avocado")!,
                                    text: "Extra Like Guac",
                                    textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-bananas")!,
                                    text: "BANANAS!",
                                    textColor: UIColor(red: 0.88, green: 0.72, blue: 0.04, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-cherry")!,
                                    text: "Cherry Bomb",
                                    textColor: UIColor(red: 0.67, green: 0.24, blue: 0.33, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-grapes")!,
                                    text: "Grapeful",
                                    textColor: UIColor(red: 0.35, green: 0.29, blue: 0.50, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-kiwi")!,
                                    text: "Klutzy Kiwi",
                                    textColor: UIColor(red: 0.64, green: 0.42, blue: 0.42, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-lemon")!,
                                    text: "Zesty",
                                    textColor: UIColor(red: 0.76, green: 0.66, blue: 0.09, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-pepper")!,
                                    text: "Spicy",
                                    textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-raddish")!,
                                    text: "Baddest Radish",
                                    textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-strawberry")!,
                                    text: "Fruity Cutie",
                                    textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
        fruitVibes.append(FruitVibe(image: UIImage(named: "fruit-vibes-watermelon")!,
                                    text: "Just Add Water",
                                    textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
        
        return fruitVibes
    }
}

// MARK: - Collection View Delegate/Data Source
extension GetStartedVibeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedItems.contains(indexPath), let index = self.selectedItems.firstIndex(of: indexPath) {
            HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
            self.selectedItems.remove(at: index)
            self.collectionView.reloadItems(at: [indexPath])
        } else {
            if self.selectedItems.count < 3 {
                HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
                self.selectedItems.append(indexPath)
                self.collectionView.reloadItems(at: [indexPath])
            } else {
                HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
            }
        }
        
        switch self.selectedItems.count {
        case 0:
            self.subtitleLabel.text = "Select up to three"
        case 1:
            self.subtitleLabel.text = "Select up to two more"
        case 2:
            self.subtitleLabel.text = "Select up to one more"
        case 3:
            self.subtitleLabel.text = "Awesome! Continue?"
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fruitVibes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let fruitVibeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FruitVibeCollectionViewCell", for: indexPath) as? FruitVibeCollectionViewCell {
            let fruit = self.fruitVibes[indexPath.item]
            fruitVibeCell.tag = indexPath.item
            fruitVibeCell.setSelected(selected: self.selectedItems.contains(indexPath))
            fruitVibeCell.setFruitVibe(fruit: fruit)
            return fruitVibeCell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let vibeWidth: CGFloat = (collectionView.frame.size.width  - betweenVibeSpacing) / 2.0
        return CGSize(width: vibeWidth, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return betweenVibeSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return betweenVibeSpacing
    }
    
}
