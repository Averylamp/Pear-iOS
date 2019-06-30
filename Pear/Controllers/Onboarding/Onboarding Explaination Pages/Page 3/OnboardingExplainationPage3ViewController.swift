//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class OnboardingExplainationPage3ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var memeImageView: UIImageView!
  
  let initializationTime: Double = CACurrentMediaTime()
  
  var relationshipStatusVC: RelationshipStatusViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage3ViewController? {
    guard let onboardingPage3VC = R.storyboard.onboardingExplainationPage3ViewController
      .instantiateInitialViewController()  else { return nil }
    return onboardingPage3VC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let relationshipStatusVC = RelationshipStatusViewController.instantiate() else {
        print("Failed to create Relationship Status VC")
        return
    }
    self.relationshipStatusVC = relationshipStatusVC
    relationshipStatusVC.delegate = self
    self.addChild(relationshipStatusVC)
    self.view.addSubview(relationshipStatusVC.view)
    relationshipStatusVC.view.translatesAutoresizingMaskIntoConstraints = false
    let centerYConstraint = NSLayoutConstraint(item: relationshipStatusVC.view as Any, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 40)
    centerYConstraint.priority = .defaultHigh
    self.view.addConstraints([
      NSLayoutConstraint(item: relationshipStatusVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      centerYConstraint,
      NSLayoutConstraint(item: relationshipStatusVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30.0),
      NSLayoutConstraint(item: relationshipStatusVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30.0)
      ])
    relationshipStatusVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    centerYConstraint.constant = 0.0
    UIView.animate(withDuration: 0.4,
                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
                   animations: {
                    relationshipStatusVC.view.alpha = 1.0
                    self.view.layoutIfNeeded()
    }, completion: nil)
    SlackHelper.shared.addEvent(text: "User Continued to relationship status modal in \(round((CACurrentMediaTime() - initializationTime) * 100) / 100)s", color: UIColor.yellow)
  }
  
  func dismissModal() {
    if let relationshipStatusVC = self.relationshipStatusVC {
      relationshipStatusVC.view.removeFromSuperview()
      relationshipStatusVC.removeFromParent()
      self.relationshipStatusVC = nil
    }
  }
}

// MARK: - Life Cycle
extension OnboardingExplainationPage3ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }

  func stylize() {
    self.titleLabel.stylizeOnboardingMemeTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
    self.memeImageView.stylizeOnboardingMemeImage()
  }
  
}

extension OnboardingExplainationPage3ViewController: RelationshipStatusModalDelegate {
  func selectedRelationshipStatus(seeking: Bool) {
    DataStore.shared.currentPearUser?.isSeeking = seeking
    SlackHelper.shared.addEvent(text: "User Picked Preferences, seeking: \(seeking) in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.blue)
    PearUpdateUserAPI.shared.updateUserIsSeeking(seeking: seeking) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user seeking \(seeking)")
        } else {
          print("Failed to update user seeking \(seeking)")
        }
      case .failure(let error):
        print("Failed to update user seeking \(seeking): \(error)")
      }
    }
    guard let basicInfoVC = OnboardingBasicInfoViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    self.dismissModal()
    self.navigationController?.pushViewController(basicInfoVC, animated: true)
  }
}
