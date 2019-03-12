//
//  FullProfileScrollingViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileScrollingViewController: UIViewController {

  @IBOutlet var scrollView: UIScrollView!
  var userProfileData: GettingStartedUserProfileData!
  
  var fullStackView: UIStackView?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(userProfileData: GettingStartedUserProfileData) -> FullProfileScrollingViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileScrollingViewController.self), bundle: nil)
    guard let fullProfileScrollingVC = storyboard.instantiateInitialViewController() as? FullProfileScrollingViewController else { return nil }
    fullProfileScrollingVC.userProfileData = userProfileData
    return fullProfileScrollingVC
  }
}

// MARK: - Life Cycle
extension FullProfileScrollingViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addFullStackVC()
    self.stylize()
  }
  
  func stylize() {
    self.view.backgroundColor = Colors.fullProfileBackgroundColor
  }
  
  func addFullStackVC() {
    guard  let fullProfileDisplayData = try? FullProfileDisplayData(gsup: self.userProfileData, creatorFirstName: ""),
      let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: fullProfileDisplayData) else {
      print("Failed to create full profiles stack VC")
      return
    }

    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    if let fullStackView = fullProfileStackVC.view as? UIStackView {
      self.fullStackView = fullStackView
    }
    self.scrollView.addConstraints([
        NSLayoutConstraint(item: fullProfileStackVC.view, attribute: .centerX, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: fullProfileStackVC.view, attribute: .width, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: fullProfileStackVC.view, attribute: .top, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: fullProfileStackVC.view, attribute: .bottom, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)
    
  }
  
}
