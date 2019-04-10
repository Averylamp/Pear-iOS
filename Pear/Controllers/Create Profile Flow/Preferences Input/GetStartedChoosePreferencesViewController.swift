//
//  GetStartedChoosePreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedChoosePreferencesViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var stackView: UIStackView!
  
  let pageNumber: CGFloat = 1.0
  
  var gettingStartedData: UserProfileCreationData!
  weak var genderPreferencesVC: UserGenderPreferencesViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedChoosePreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedChoosePreferencesViewController.self), bundle: nil)
    guard let choosePreferencesVC = storyboard.instantiateInitialViewController() as? GetStartedChoosePreferencesViewController else { return nil }
    choosePreferencesVC.gettingStartedData = gettingStartedData
    return choosePreferencesVC
  }
  
  @IBAction func nextButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let schoolVC = GetStartedSchoolViewController.instantiate(gettingStartedData: self.gettingStartedData) {
      Analytics.logEvent("CP_done_preferences", parameters: nil)
      self.navigationController?.pushViewController(schoolVC, animated: true)
    } else {
      print("Failed to create School VC")
      return
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
    Analytics.logEvent("CP_back_preferences", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedChoosePreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupFriendPreferences()
    self.stylize()
  }
  
  func setupFriendPreferences() {
    
//    guard let currentUser = DataStore.shared.currentPearUser else {
//      print("Failed to fetch user")
//      return
//    }
    
    var seekingGender = self.gettingStartedData.seekingGender
    if seekingGender.count == 0,
      let friendGender = self.gettingStartedData.gender {
      if friendGender == .male {
        seekingGender.append(.female)
      } else if friendGender == .female {
        seekingGender.append(.male)
      } else if friendGender == .nonbinary {
        seekingGender = [.male, .female, .nonbinary]
      }
    }
    
    guard let userGenderPreferencesVC = UserGenderPreferencesViewController.instantiate(genderPreferences: seekingGender) else {
      print("Unable to instantiate user gender preferences vc")
      return
    }
    stackView.addArrangedSubview(userGenderPreferencesVC.view)
    self.addChild(userGenderPreferencesVC)
    self.genderPreferencesVC = userGenderPreferencesVC
    userGenderPreferencesVC.didMove(toParent: self)
  }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.nextButton.stylizeDark()
    
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

extension GetStartedChoosePreferencesViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
