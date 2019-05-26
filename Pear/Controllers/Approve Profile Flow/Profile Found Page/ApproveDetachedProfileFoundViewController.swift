//
//  DetachedProfileFoundViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth

class ApproveDetachedProfileFoundViewController: UIViewController {

  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var friendImage: UIImageView!
  @IBOutlet weak var friendImageHeightConstraint: NSLayoutConstraint!
  
  var isApprovingProfile = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileFoundViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileFoundViewController.self), bundle: nil)
    guard let detachedProfileFoundVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileFoundViewController else { return nil }
    detachedProfileFoundVC.detachedProfile = detachedProfile
    
    return detachedProfileFoundVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    if self.isApprovingProfile {
      return
    }
    self.isApprovingProfile = true
    self.nextButton.alpha = 0.5
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    if let currentUserID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.attachDetachedProfile(detachedProfile: self.detachedProfile) { (result) in
        DispatchQueue.main.async {
          self.nextButton.alpha = 1.0
          switch result {
          case .success(let success):
            HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
            print("Successfully attached detached profile: \(success)")
            if success {
              DataStore.shared.refreshPearUser(completion: nil)
              DataStore.shared.refreshEndorsedUsers(completion: nil)
              DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
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
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ApproveDetachedProfileFoundViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    detachedProfile.questionResponses.forEach({self.addAnsweredPrompt(response: $0)})
  }
  
  func stylize() {
    self.nextButton.stylizeSaveToProfileButton()
    if let font = R.font.openSansBold(size: 24) {
      self.titleLabel.font = font
    }
    var creatorFirstName = "Someone"
    if self.detachedProfile.creatorFirstName != nil {
      creatorFirstName = self.detachedProfile.creatorFirstName
    }
    if self.detachedProfile.questionResponses.count == 1 {
      self.titleLabel.text = "\(creatorFirstName) answered a prompt for you."
    } else {
      self.titleLabel.text = "\(creatorFirstName) answered \(self.detachedProfile.questionResponses.count) prompts for you."
    }
    
    if let creatorThumbnailURL = self.detachedProfile.creatorThumbnailURL,
      let friendImage = self.friendImage,
      let imageURL = URL(string: creatorThumbnailURL) {
      friendImage.sd_setImage(with: imageURL, completed: nil)
    }
    
    self.friendImage.layer.cornerRadius = self.friendImage.frame.width / 2.0
    self.friendImage.clipsToBounds = true
    self.friendImage.layer.borderWidth = 4
    self.friendImage.layer.borderColor = UIColor(red: 0.29, green: 0.86, blue: 0.52, alpha: 1.0).cgColor
    
    if UIScreen.main.bounds.width <= 320 {
      self.friendImageHeightConstraint.constant = 0
      self.friendImage.isHidden = true
    }
  }
}

//MARK: - Prompt Generation
extension ApproveDetachedProfileFoundViewController {
  
  func addAnsweredPrompt(response: QuestionResponseItem) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let cardView = UIView()
    cardView.isUserInteractionEnabled = false
    cardView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(cardView)
    cardView.layer.cornerRadius = 12
    cardView.layer.borderWidth = 2.0
    cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 6.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -6.0)
      ])
    
    let promptLabel = UILabel()
    promptLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 14.0) {
      promptLabel.font = font
    }
    promptLabel.text = response.question.questionText
    promptLabel.textColor = R.color.primaryTextColor()
    promptLabel.numberOfLines = 0
    cardView.addSubview(promptLabel)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptLabel, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: promptLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12.0)
      
      ])
    
    let responseLabel = UILabel()
    responseLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansSemiBold(size: 14) {
      responseLabel.font = font
    }
    responseLabel.text = response.responseBody
    responseLabel.textColor = R.color.secondaryTextColor()
    responseLabel.numberOfLines = 0
    cardView.addSubview(responseLabel)
    cardView.addConstraints([
      NSLayoutConstraint(item: responseLabel, attribute: .top, relatedBy: .equal,
                         toItem: promptLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: responseLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: responseLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -12.0)
      ])
    
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = R.image.updateUserIconMoreIcon()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(imageView)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptLabel, attribute: .right, relatedBy: .equal,
                         toItem: imageView, attribute: .left, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: responseLabel, attribute: .right, relatedBy: .equal,
                         toItem: imageView, attribute: .left, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -12.0),
      NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                         toItem: cardView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26.0),
      NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26.0)
      ])
    
    self.stackView.addArrangedSubview(containerView)
  }

}
