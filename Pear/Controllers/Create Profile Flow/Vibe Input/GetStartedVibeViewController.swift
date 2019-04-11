//
//  GetStartedVibeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

struct FruitVibe {
  let image: UIImage?
  let text: String
  let textColor: UIColor
}

class GetStartedVibeViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var nextButton: UIButton!
  var gettingStartedData: UserProfileCreationData!
  var fruitVibes: [FruitVibe] = []
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 5.0
  
  let betweenVibeSpacing: CGFloat = 12
  var selectedItems: [IndexPath] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedVibeViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedVibeViewController.self), bundle: nil)
    guard let interestsVC = storyboard.instantiateInitialViewController() as? GetStartedVibeViewController else { return nil }
    interestsVC.gettingStartedData = gettingStartedData
    return interestsVC
  }
  
  func saveVibes() {
    self.gettingStartedData.vibes = []
    for indexPath in self.selectedItems {
      let fruitVibe = self.fruitVibes[indexPath.item]
      self.gettingStartedData.vibes.append(fruitVibe.text.lowercased())
    }
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveVibes()
    if self.gettingStartedData.vibes.count == 0 {
      self.alert(title: "Missing Vibe", message: "Your friend is missing their vibes!  Please choose one!")
      return
    }
    guard let doDontVC = GetStartedDoDontViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create photoInputVC")
      return
    }
    Analytics.logEvent("CP_done_vibes", parameters: nil)
    self.navigationController?.pushViewController(doDontVC, animated: true)
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Stop Making a Profile?", message: "Are you sure you want to cancel", preferredStyle: .alert)
    let continueAction = UIAlertAction(title: "Keep Going", style: .default, handler: nil)
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to initialize Main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
    alertController.addAction(continueAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.saveVibes()
    Analytics.logEvent("CP_back_vibes", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
}

// MARK: - Life Cycle
extension GetStartedVibeViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupCollectionView()
    self.stylize()
    self.restoreState()
  }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.nextButton.stylizeDark()
    self.progressWidthConstraint.constant = (pageNumber - 1) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
  }
  
  func restoreState() {
    var needsReload: Bool = false
    for vibe in self.gettingStartedData.vibes {
      if let firstIndex = self.fruitVibes.firstIndex(where: { (fruitVibe) -> Bool in
        return fruitVibe.text.lowercased() == vibe
      }) {
        needsReload = true
        let selectedIndex = IndexPath(item: firstIndex, section: 0)
        self.selectedItems.append(selectedIndex)
      }
      
    }
    if needsReload {
      self.collectionView.reloadData()
      self.updateSubtitleLabel()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesApple(),
                                text: "Forbidden Fruit",
                                textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesCoconut(),
                                text: "Coco-nuts",
                                textColor: UIColor(red: 0.51, green: 0.33, blue: 0.35, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesAvocado(),
                                text: "Extra Like Guac",
                                textColor: UIColor(red: 0.00, green: 0.62, blue: 0.59, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesBananas(),
                                text: "BANANAS!",
                                textColor: UIColor(red: 0.88, green: 0.72, blue: 0.04, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesCherry(),
                                text: "Cherry Bomb",
                                textColor: UIColor(red: 0.67, green: 0.24, blue: 0.33, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesGrapes(),
                                text: "Grapeful",
                                textColor: UIColor(red: 0.35, green: 0.29, blue: 0.50, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesKiwi(),
                                text: "Klutzy Kiwi",
                                textColor: UIColor(red: 0.64, green: 0.42, blue: 0.42, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesLemon(),
                                text: "Zesty",
                                textColor: UIColor(red: 0.76, green: 0.66, blue: 0.09, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesPepper(),
                                text: "Spicy",
                                textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesRaddish(),
                                text: "Baddest Radish",
                                textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesStrawberry(),
                                text: "Fruity Cutie",
                                textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesWatermelon(),
                                text: "Just Add Water",
                                textColor: UIColor(red: 0.85, green: 0.34, blue: 0.42, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesPear(),
                                text: "Pearfect",
                                textColor: UIColor(red: 0.26, green: 0.76, blue: 0.36, alpha: 1.00)))
    fruitVibes.append(FruitVibe(image: R.image.fruitVibesPomegranny(),
                                text: "Pomegranny",
                                textColor: UIColor(red: 0.79, green: 0.31, blue: 0.40, alpha: 1.00)))
    
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
    self.updateSubtitleLabel()
  }
  
  func updateSubtitleLabel() {
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

extension GetStartedVibeViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
