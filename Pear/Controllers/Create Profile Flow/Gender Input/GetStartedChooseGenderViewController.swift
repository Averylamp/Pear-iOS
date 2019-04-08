//
//  GetStartedChooseGenderViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedChooseGenderViewController: UIViewController {
  
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 1.0
  
  var gettingStartedData: UserProfileCreationData!
  
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  @IBOutlet weak var nonbinaryButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedChooseGenderViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedChooseGenderViewController.self), bundle: nil)
    guard let chooseGenderVC = storyboard.instantiateInitialViewController() as? GetStartedChooseGenderViewController else { return nil }
    chooseGenderVC.gettingStartedData = gettingStartedData
    return chooseGenderVC
  }
  
  @IBAction func chooseGenderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    switch sender.tag {
    case 0:
      self.gettingStartedData.gender = GenderEnum.male
      self.maleButton.stylizeDark()
      self.femaleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 1:
      self.gettingStartedData.gender = GenderEnum.female
      self.femaleButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 2:
      self.gettingStartedData.gender = GenderEnum.nonbinary
      self.nonbinaryButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.femaleButton.stylizeLight()
      
    default:
      break
    }
    
    if let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData) {
      Analytics.logEvent("finished_friend_gender", parameters: nil)
      self.navigationController?.pushViewController(interestsVC, animated: true)
    } else {
      print("Failed to create Interests VC")
    }
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
    Analytics.logEvent("clicked_friend_gender_back", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedChooseGenderViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }
  
  func stylize() {
    
    self.maleButton.stylizeLight()
    self.maleButton.tag = 0
    
    self.femaleButton.stylizeLight()
    self.femaleButton.tag = 1
    
    self.nonbinaryButton.stylizeLight()
    self.nonbinaryButton.tag = 2
    
    if let previousGender = self.gettingStartedData.gender {
      switch previousGender {
      case .male:
        self.maleButton.stylizeDark()
      case .female:
        self.femaleButton.stylizeDark()
      case .nonbinary:
        self.nonbinaryButton.stylizeDark()
      }
    }
    
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
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
  
}

extension GetStartedChooseGenderViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
