//
//  EditPreviewViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class EditPreviewViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var previewButton: UIButton!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  
  weak var editUserVC: MeEditUserInfoStackViewController?
  var previousFullProfileDisplayData: FullProfileDisplayData?
  var lastRefesthTime = CACurrentMediaTime()
  var lastScrollPosition: CGFloat = 0.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> EditPreviewViewController? {
    guard let editPreviewVC = R.storyboard.editPreviewViewController
      .instantiateInitialViewController() else { return nil }
    return editPreviewVC
  }

  @IBAction func doneButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let editsMade = self.editUserVC?.checkForEdits(), editsMade {
      self.editUserVC?.saveChanges(completion: {
        DispatchQueue.main.async {
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
          self.navigationController?.popViewController(animated: true)
        }
      })
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func editButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.editButton.isSelected = true
    self.previewButton.isSelected = false
    self.scrollView.setContentOffset(CGPoint.zero, animated: true)
  }
  
  @IBAction func previewButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.editButton.isSelected = false
    self.previewButton.isSelected = true
    self.refreshPreviewVCIfNeeded()
    self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: true)
  }
  
}

// MARK: - Life Cycle
extension EditPreviewViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.scrollView.isPagingEnabled = true
    self.scrollView.delegate = self
    self.editButton.isSelected = true
    self.previewButton.isSelected = false
    self.scrollView.contentOffset = CGPoint.zero
    self.stackView.arrangedSubviews.forEach({
      $0.removeFromSuperview()
      self.stackView.removeArrangedSubview($0)
    })
    self.addEditUserVC()
    self.refreshPreviewVCIfNeeded()
  }
  
  func addEditUserVC() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to get pear user")
      return
    }
    let fullProfileDisplay = FullProfileDisplayData(user: user)
    
    guard let editUserVC = MeEditUserInfoStackViewController.instantiate(profile: fullProfileDisplay, pearUser: user) else {
      print("Unable to create edit user VC")
      return
    }
    self.editUserVC = editUserVC
    self.addChild(editUserVC)
    editUserVC.view.translatesAutoresizingMaskIntoConstraints = false
    let containerScrollView = UIScrollView()
    containerScrollView.translatesAutoresizingMaskIntoConstraints = false
    containerScrollView.showsHorizontalScrollIndicator = false
    containerScrollView.showsVerticalScrollIndicator = false
    
    containerScrollView.addSubview(editUserVC.view)
    
    containerScrollView.addConstraints([
      NSLayoutConstraint(item: editUserVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])

    self.stackView.addArrangedSubview(containerScrollView)
    self.view.addConstraints([
      NSLayoutConstraint(item: containerScrollView, attribute: .width, relatedBy: .equal,
                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    editUserVC.didMove(toParent: self)
  }
  
  func refreshPreviewVCIfNeeded() {
    self.lastRefesthTime = CACurrentMediaTime()
    print("Refresh preview if needed")
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to find user")
      return
    }
    let fullProfileDisplayData = FullProfileDisplayData(user: user)
    if let userEditsMade = self.editUserVC?.checkForEdits(),
      userEditsMade,
      let editedImageContainers = self.editUserVC?.photoUpdateVC?.images.compactMap({ $0.imageContainer }) {
      fullProfileDisplayData.imageContainers = editedImageContainers
    }

    if let previousFullProfileDisplayData = self.previousFullProfileDisplayData {
      if fullProfileDisplayData == previousFullProfileDisplayData {
        print("No Refresh Needed")
        return
      }
    }
    print("Refreshing Full Profile Display Preview")
    self.previousFullProfileDisplayData = fullProfileDisplayData
    if self.stackView.arrangedSubviews.count == 2 {
      let previousPreviewVCView = self.stackView.arrangedSubviews[1]
      self.stackView.removeArrangedSubview(previousPreviewVCView)
      previousPreviewVCView.removeFromSuperview()
    }
  
    guard let profileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: fullProfileDisplayData) else {
      print("Unable to create full profile stack View")
      return
    }
    self.addChild(profileStackVC)
    profileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    let containerScrollView = UIScrollView()
    containerScrollView.translatesAutoresizingMaskIntoConstraints = false
    containerScrollView.showsHorizontalScrollIndicator = false
    containerScrollView.showsVerticalScrollIndicator = false
    
    containerScrollView.addSubview(profileStackVC.view)
    
    containerScrollView.addConstraints([
      NSLayoutConstraint(item: profileStackVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileStackVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileStackVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileStackVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileStackVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: containerScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
    self.stackView.addArrangedSubview(containerScrollView)
    self.view.addConstraints([
      NSLayoutConstraint(item: containerScrollView, attribute: .width, relatedBy: .equal,
                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])

    profileStackVC.didMove(toParent: self)
  }
  
  /// Stylize can be called more than once
  func stylize() {
    self.scrollView.showsHorizontalScrollIndicator = false
    self.editButton.setTitleColor(R.color.primaryTextColor(), for: .selected)
    self.editButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
    self.previewButton.setTitleColor(R.color.primaryTextColor(), for: .selected)
    self.previewButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
    self.titleLabel.stylizeGeneralHeaderTitleLabel()
    if let font = R.font.openSansBold(size: 16) {
      self.editButton.titleLabel?.font = font
      self.previewButton.titleLabel?.font = font
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension EditPreviewViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x > self.lastScrollPosition && CACurrentMediaTime() - self.lastRefesthTime > 2.0 {
      self.refreshPreviewVCIfNeeded()
    }
    self.lastScrollPosition = scrollView.contentOffset.x
  }
  
}
