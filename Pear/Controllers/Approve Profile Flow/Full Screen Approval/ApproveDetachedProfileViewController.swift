//
//  DetachedProfileApprovalViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveDetachedProfileViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 2.0
  var isApprovingProfile = false
  
  var detachedProfile: PearDetachedProfile!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileViewController else { return nil }
    doDontVC.detachedProfile = detachedProfile
    return doDontVC
  }
  
  @objc func skipButtonClicked(sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    
    self.navigationController?.popViewController(animated: true)
    
  }
  
  @objc func saveButtonClicked(sender: UIButton) {
    // @bgu Profile Attach network call here
    return
    /*
    if self.isApprovingProfile {
      return
    }
    self.isApprovingProfile = true
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    if let currentUserID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.attachDetachedProfile(detachedProfile: self.detachedProfile) { (result) in
        DispatchQueue.main.async {
          
          switch result {
          case .success(let success):
            HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
            print("Successfully attached detached profile: \(success)")
            if success {
              DataStore.shared.refreshPearUser(completion: nil)
              DataStore.shared.refreshEndorsedUsers(completion: nil)
              if DataStore.shared.hasUpdatedPreferences() {
                DataStore.shared.getNotificationAuthorizationStatus { status in
                  print("**NOTIF AUTH STATUS**")
                  print(status)
                  if status == .notDetermined {
                    DispatchQueue.main.async {
                      guard let allowNotificationVC = ApproveProfileAllowNotificationsViewController.instantiate() else {
                        print("Failed to create Allow Notifications VC")
                        return
                      }
                      self.navigationController?.setViewControllers([allowNotificationVC], animated: true)
                    }
                  } else {
                    DispatchQueue.main.async {
                      self.dismiss(animated: true, completion: nil)
                    }
                  }
                }
              } else {
                guard let updateUserVC = UpdateUserPreferencesViewController.instantiate() else {
                  print("Failed to initialize Update User Pref VC")
                  return
                }
                self.navigationController?.setViewControllers([updateUserVC], animated: true)
              }
            } else {
              HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
              self.alert(title: "Failed to Accept", message: "Unfortunately there was a problem with our servers.  Try again later")
            }
          case .failure(let error):
            HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
            self.alert(title: "Failed to Accept", message: "Unfortunately there was a problem with our servers.  Try again later")
            print("Failed to attach detached profile: \(error)")
          }
          self.isApprovingProfile = false
        }
        
      }
    }
     */
  }
}

// MARK: - Life Cycle
extension ApproveDetachedProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addFullStackVC()
    self.stylize()
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController
      .instantiate(userFullProfileData: FullProfileDisplayData(detachedProfile: self.detachedProfile)) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    let continueContainerView = UIView()
    continueContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let continueButton = UIButton()
    continueButton.addTarget(self, action: #selector(ApproveDetachedProfileViewController.saveButtonClicked(sender:)), for: .touchUpInside)
    continueButton.stylizeDark()
    continueButton.layer.cornerRadius = 25
    continueButton.setTitle("Continue", for: .normal)
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueButton)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueButton, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueButton, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueButton, attribute: .top, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .top, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: continueButton, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
      ])
    
    let continueSubtext = UILabel()
    continueSubtext.stylizeTextFieldTitle()
    continueSubtext.numberOfLines = 0
    continueSubtext.textAlignment = .center
    continueSubtext.text = "This will make your profile visible to other users on Pear and your friend will be able to edit their contributions to your profile in the future."
    continueSubtext.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueSubtext)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueSubtext, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .top, relatedBy: .equal,
                         toItem: continueButton, attribute: .bottom, multiplier: 1.0, constant: 10.0)
      ])
    
    let skipButton = UIButton()
    skipButton.addTarget(self,
                         action: #selector(ApproveDetachedProfileViewController.skipButtonClicked(sender:)), for: .touchUpInside)
    skipButton.stylizeSubtle()
    skipButton.setTitle("Reject Profile", for: .normal)
    skipButton.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(skipButton)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: skipButton, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: skipButton, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: skipButton, attribute: .top, relatedBy: .equal,
                         toItem: continueSubtext, attribute: .bottom, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: skipButton, attribute: .bottom, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
      ])
    
    fullProfileStackVC.stackView.addArrangedSubview(continueContainerView)
    
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)
    
  }
  
  func stylize() {
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()

  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}
