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
    
    self.addFullStackVC()
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: self.fullProfileData) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    let continueContainerView = UIView()
    continueContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let continueButton = UIButton()
    continueButton.addTarget(self, action: #selector(FullProfileReviewViewController.nextButtonClicked(_:)), for: .touchUpInside)
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
