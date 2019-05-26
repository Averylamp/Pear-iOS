//
//  JoinEventViewController.swift
//  Pear
//
//  Created by Brian Gu on 5/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class JoinEventViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var skipEventButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> JoinEventViewController? {
    guard let joinEventVC = R.storyboard.joinEventViweController()
      .instantiateInitialViewController() as? JoinEventViewController else { return nil }
    return joinEventVC
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.continueToLocationOrNext()
  }
  
}

// MARK: - Permissions Flow Protocol
extension JoinEventViewController: PermissionsFlowProtocol {
  // No-Op
}

// MARK: - Life Cycle
extension JoinEventViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.titleLabel.stylizeUserSignupTitleLabel()
    self.skipEventButton.stylizeOnboardingContinueButton()
    self.skipEventButton.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
    self.skipEventButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
  }
  
  func setup() {
    let containerButton = UIButton()
    containerButton.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addTarget(self, action: #selector(JoinEventViewController.addDMFEvent), for: .touchUpInside)
    self.view.addSubview(containerButton)
    let cardView = UIView()
    cardView.isUserInteractionEnabled = false
    cardView.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addSubview(cardView)
    cardView.layer.cornerRadius = 12
    cardView.layer.borderWidth = 2.0
    cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
    self.view.addConstraints([
      NSLayoutConstraint(item: containerButton, attribute: .top, relatedBy: .equal,
                         toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 16),
      NSLayoutConstraint(item: containerButton, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: containerButton, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -12)
      ])
    containerButton.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerButton, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerButton, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerButton, attribute: .top, multiplier: 1.0, constant: 6.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerButton, attribute: .bottom, multiplier: 1.0, constant: -6.0)
      ])
    let promptLabel = UILabel()
    promptLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 16.0) {
      promptLabel.font = font
    }
    promptLabel.text = "Date My Friend.ppt, 6/2"
    promptLabel.textColor = R.color.primaryTextColor()
    promptLabel.addConstraint(NSLayoutConstraint(item: promptLabel, attribute: .height, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
    cardView.addSubview(promptLabel)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptLabel, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: promptLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: promptLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
      ])
    
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = R.image.updateUserIconForwardArrow()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(imageView)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptLabel, attribute: .right, relatedBy: .equal,
                         toItem: imageView, attribute: .left, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -12.0),
      NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                         toItem: cardView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26.0),
      NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26.0)
      ])
  }
  
  @objc func addDMFEvent(_ sender: UIButton) {
    print("tapped DMF button")
  }
  
}
