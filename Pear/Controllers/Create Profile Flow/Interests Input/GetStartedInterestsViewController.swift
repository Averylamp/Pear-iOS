//
//  GetStartedInterestsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetStartedInterestsViewController: UIViewController {
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat  = 3.0
  var gettingStartedData: UserProfileCreationData!
  
  var interestStrings: [String] = []
  
  static let defaultInterestStrings: [String] = [
    "Language",
    "Pets",
    "Outdoors",
    "Poetry",
    "Travel",
    "DIY/Crafts",
    "Health",
    "Storytelling",
    "Anime",
    "Instruments",
    "Politics",
    "Environment",
    "Beauty/Makeup",
    "Sci-Fi/Fantasy",
    "Science",
    "Board Games",
    "Art and Design",
    "Technology",
    "Music",
    "Concerts",
    "Gaming",
    "Fashion",
    "Movies",
    "Cars",
    "Cooking",
    "Food",
    "Dance",
    "Religion",
    "Volunteering",
    "Sports",
    "Gym",
    "Photography",
    "Performing arts"
  ]
  
  var interestButtons: [UIButton] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedInterestsViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedInterestsViewController.self), bundle: nil)
    guard let interestsVC = storyboard.instantiateInitialViewController() as? GetStartedInterestsViewController else { return nil }
    interestsVC.gettingStartedData = gettingStartedData
    let cloudInterestsData =  DataStore.shared.remoteConfig.configValue(forKey: "interests_values").dataValue
    if let cloudJSON = try? JSON(data: cloudInterestsData),
      let cloudInterests = cloudJSON.array {
      let interestStrings = cloudInterests.compactMap({$0.string})
      interestsVC.interestStrings = interestStrings
    } else {
      interestsVC.interestStrings = GetStartedInterestsViewController.defaultInterestStrings
    }
    return interestsVC
  }
  
  func saveInterests() {
    self.gettingStartedData.interests = []
    for button in self.interestButtons where button.isSelected {
      self.gettingStartedData.interests.append(button.titleLabel!.text!)
    }
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.saveInterests()
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveInterests()
    guard let vibesVC = GetStartedVibeViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create vibes VC")
      return
    }
    self.navigationController?.pushViewController(vibesVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedInterestsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupInterestButtons()
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
  
  func setupInterestButtons() {
    self.view.layoutIfNeeded()
    let numRows = Int(ceil(Double(interestStrings.count) / 3.0))
    let sideOffset: CGFloat = 25
    let buttonSpacing: CGFloat = 8
    let buttonHeight: CGFloat = 40
    let rowHeight = buttonHeight + buttonSpacing
    let buttonWidth = (self.scrollView.frame.width - (2 * sideOffset + 2 * buttonSpacing)) / 3
    for itemNumber in 0..<numRows {
      let leftButton  = UIButton()
      leftButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
      self.scrollView.addSubview(leftButton)
      leftButton.setTitle(interestStrings[itemNumber * 3], for: .normal)
      leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      leftButton.titleLabel?.minimumScaleFactor = 0.5
      leftButton.titleLabel?.adjustsFontSizeToFitWidth = true
      leftButton.frame = CGRect(x: sideOffset, y: buttonSpacing + rowHeight * CGFloat(itemNumber), width: buttonWidth, height: buttonHeight)
      leftButton.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1.00)
      leftButton.layer.cornerRadius = buttonHeight / 2.0
      leftButton.setTitleColor(UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.00), for: .normal)
      leftButton.setTitleColor(UIColor(red: 0.00, green: 0.75, blue: 0.44, alpha: 1.00), for: .selected)
      leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
      self.interestButtons.append(leftButton)
      
      if itemNumber * 3 + 1 < interestStrings.count {
        let centerButton  = UIButton()
        centerButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
        self.scrollView.addSubview(centerButton)
        centerButton.setTitle(interestStrings[itemNumber * 3 + 1], for: .normal)
        centerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        centerButton.frame = CGRect(x: sideOffset + (buttonWidth + buttonSpacing), y: buttonSpacing + rowHeight * CGFloat(itemNumber),
                                    width: buttonWidth, height: buttonHeight)
        centerButton.titleLabel?.minimumScaleFactor = 0.5
        centerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        centerButton.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1.00)
        centerButton.layer.cornerRadius = buttonHeight / 2.0
        centerButton.setTitleColor(UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.00), for: .normal)
        centerButton.setTitleColor(UIColor(red: 0.00, green: 0.75, blue: 0.44, alpha: 1.00), for: .selected)
        centerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.interestButtons.append(centerButton)
      }
      
      if itemNumber * 3 + 2 < interestStrings.count {
        let rightButton  = UIButton()
        rightButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
        self.scrollView.addSubview(rightButton)
        rightButton.setTitle(interestStrings[itemNumber * 3 + 2], for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        rightButton.frame = CGRect(x: sideOffset + (buttonWidth + buttonSpacing) * 2, y: buttonSpacing + rowHeight * CGFloat(itemNumber),
                                   width: buttonWidth, height: buttonHeight)
        rightButton.titleLabel?.minimumScaleFactor = 0.5
        rightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        rightButton.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1.00)
        rightButton.layer.cornerRadius = buttonHeight / 2.0
        rightButton.setTitleColor(UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.00), for: .normal)
        rightButton.setTitleColor(UIColor(red: 0.00, green: 0.75, blue: 0.44, alpha: 1.00), for: .selected)
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.interestButtons.append(rightButton)
      }
      
    }
    
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: rowHeight * CGFloat(numRows) + 2.0 * buttonSpacing)
    
    for button in self.interestButtons {
      if self.gettingStartedData.interests.contains(button.titleLabel!.text!) {
        self.toggleInterestButton(button: button, initialization: true)
      }
    }
    
  }
  
  func toggleInterestButton(button: UIButton, initialization: Bool = false) {
    if !initialization {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    }
    if button.isSelected {
      button.isSelected = false
      button.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1.00)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    } else {
      button.isSelected = true
      button.backgroundColor = UIColor(red: 0.84, green: 0.98, blue: 0.93, alpha: 1.00)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
  }
  
  @objc func interestButtonClicked(sender: UIButton) {
    toggleInterestButton(button: sender)
  }
  
}