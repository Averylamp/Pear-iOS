//
//  FullProfileScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileScrollViewController: UIViewController {

  var fullProfileData: FullProfileDisplayData!
  
  @IBOutlet weak var firstNameLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> FullProfileScrollViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileScrollViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? FullProfileScrollViewController else { return nil }
    doDontVC.fullProfileData = fullProfileData
    return doDontVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
}

// MARK: - Life Cycle
extension FullProfileScrollViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.addFullStackVC()
    self.stylize()
  }
  
  func stylize() {
    self.firstNameLabel.stylizeSubtitleLabelSmall()
    self.firstNameLabel.text = self.fullProfileData.firstName
    self.scrollView.backgroundColor = R.color.cardBackgroundColor()
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: self.fullProfileData) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
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
}

extension FullProfileScrollViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
