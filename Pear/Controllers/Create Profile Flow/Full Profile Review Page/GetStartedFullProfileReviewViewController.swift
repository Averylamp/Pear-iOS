//
//  GetStartedFullProfileReviewViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedFullProfileReviewViewController: UIViewController {
  
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat  = 8.0
  
  @IBOutlet weak var scrollView: UIScrollView!
  var gettingStartedUserProfileData: UserProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserProfileData: UserProfileCreationData) -> GetStartedFullProfileReviewViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedFullProfileReviewViewController.self), bundle: nil)
    guard let fullProfileReviewVC = storyboard.instantiateInitialViewController() as? GetStartedFullProfileReviewViewController else { return nil }
    fullProfileReviewVC.gettingStartedUserProfileData = gettingStartedUserProfileData
    print(gettingStartedUserProfileData)
    return fullProfileReviewVC
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
    Analytics.logEvent("CP_review_back", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let notifyFriendVC = GetStartedNotifyFriendViewController.instantiate(gettingStartedData: self.gettingStartedUserProfileData) else {
      print("Failed to create Notify Friend VC")
      return
    }
    Analytics.logEvent("finished_friend_review", parameters: nil)
    self.navigationController?.pushViewController(notifyFriendVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedFullProfileReviewViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addFullStackVC()
    self.stylize()
  }
    
  func addFullStackVC() {
    guard let creatorFirstName = DataStore.shared.currentPearUser?.firstName,
      let fullProfileData = try? FullProfileDisplayData(gsup: self.gettingStartedUserProfileData, creatorFirstName: creatorFirstName),
      let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: fullProfileData) else {
      print("Failed to create full profiles stack VC")
      return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    let continueContainerView = UIView()
    continueContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let continueButton = UIButton()
    continueButton.addTarget(self, action: #selector(GetStartedFullProfileReviewViewController.nextButtonClicked(_:)), for: .touchUpInside)
    continueButton.stylizeDark()
    continueButton.layer.cornerRadius = 25
    continueButton.setTitle("Looks good?", for: .normal)
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
    continueSubtext.text = "Your friend will have to approve their profile for it to be surfaced to the public. \nAre you ready to send it over to your friend?"
    continueSubtext.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueSubtext)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueSubtext, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .top, relatedBy: .equal,
                         toItem: continueButton, attribute: .bottom, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .bottom, relatedBy: .equal,
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
    
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

extension GetStartedFullProfileReviewViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
