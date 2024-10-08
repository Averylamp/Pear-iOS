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
import FirebaseAnalytics

class JoinEventViewController: OnboardingViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var skipEventButton: UIButton!
  
  var eventCode: String!
  var isAddingEvent: Bool!
  var isInOnboarding: Bool!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(isInOnboarding: Bool) -> JoinEventViewController? {
    guard let joinEventVC = R.storyboard.joinEventViweController
      .instantiateInitialViewController() else { return nil }
    joinEventVC.eventCode = ""
    joinEventVC.isAddingEvent = false
    joinEventVC.isInOnboarding = isInOnboarding
    return joinEventVC
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    if self.isAddingEvent {
      return
    }
    if self.isInOnboarding {
      self.continueToLocationOrNext()
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
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
    var promptLabelFontSize = 18.0
    if UIScreen.main.bounds.width <= 320 {
      promptLabelFontSize = 16.0
    }
    if let font = R.font.openSansBold(size: CGFloat(promptLabelFontSize)) {
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
    
    let seeEventLabel = UILabel()
    seeEventLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansSemiBold(size: 14.0) {
      seeEventLabel.font = font
    }
    seeEventLabel.text = "Don't see your event?"
    seeEventLabel.textColor = R.color.tertiaryTextColor()
    self.view.addSubview(seeEventLabel)
    self.view.addConstraints([
      NSLayoutConstraint(item: seeEventLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerButton, attribute: .bottom, multiplier: 1.0, constant: 5.0),
      NSLayoutConstraint(item: seeEventLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
      ])
    
    let enterCodeButton = UIButton()
    enterCodeButton.addTarget(self, action: #selector(JoinEventViewController.enterCodeClicked), for: .touchUpInside)
    enterCodeButton.translatesAutoresizingMaskIntoConstraints = false
    enterCodeButton.setTitle("Enter event code", for: .normal)
    if let font = R.font.openSansBold(size: 14.0) {
      enterCodeButton.titleLabel?.font = font
    }
    enterCodeButton.setTitleColor(R.color.primaryBrandColor(), for: .normal)
    self.view.addSubview(enterCodeButton)
    self.view.addConstraints([
      NSLayoutConstraint(item: enterCodeButton, attribute: .top, relatedBy: .equal,
                         toItem: seeEventLabel, attribute: .bottom, multiplier: 1.0, constant: -2.0),
      NSLayoutConstraint(item: enterCodeButton, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
      ])
  }
  
  @objc func addDMFEvent(_ sender: UIButton) {
    if self.isAddingEvent {
      return
    }
    print("tapped DMF button")
    Analytics.logEvent("join_event", parameters: nil)
    self.isAddingEvent = true
    PearUserAPI.shared.addEventCode(code: "SUMMERLOVE") { (result) in
      self.isAddingEvent = false
      switch result {
      case .success(let successful):
        if successful {
          if self.isInOnboarding {
            self.continueToLocationOrNext()
          } else {
            self.dismiss(animated: true, completion: nil)
          }
        } else {
          DispatchQueue.main.async {
            self.alert(title: "Error adding event",
                       message: "Unfortunately we are unable to complete this operation at this time. Please try again later")
          }
        }
      case .failure(let error):
        print("Failure adding event code SUMMERLOVE: \(error)")
        DispatchQueue.main.async {
          self.alert(title: "Error adding event",
                     message: "Unfortunately we are unable to complete this operation at this time. Please try again later")
        }
      }
      
    }
  }
  
  @objc func enterCodeClicked(_ sender: UIButton) {
    if self.isAddingEvent {
      return
    }
    print("tapped enter code button")
    let alertController = UIAlertController(title: "Welcome!", message: "Please enter your event code to continue.", preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "Enter the code"
    }
    let submitAction = UIAlertAction(title: "Continue", style: .default) { (_) in
      let textField = alertController.textFields![0] as UITextField
      if let text = textField.text {
        self.eventCode = text
      }
      print(self.eventCode)
      self.isAddingEvent = true
      PearUserAPI.shared.addEventCode(code: self.eventCode) { (result) in
        self.isAddingEvent = false
        switch result {
        case .success(let successful):
          if successful {
            if self.isInOnboarding {
              self.continueToLocationOrNext()
            } else {
              self.dismiss(animated: true, completion: nil)
            }
          } else {
            DispatchQueue.main.async {
              self.alert(title: "No event found",
                         message: "We couldn't find an event with this code.")
            }
          }
        case .failure(let error):
          print("Failure adding event code SUMMERLOVE: \(error)")
          DispatchQueue.main.async {
            self.alert(title: "No event found",
                       message: "We couldn't find an event with this code.")
          }
        }
        
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(submitAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
}
