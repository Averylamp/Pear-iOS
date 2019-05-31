//
//  UpdateUserPromptsStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UpdateUserPromptsStackViewController: UIViewController {
  
  @IBOutlet var stackView: UIStackView!
  
  let edgeSpace: CGFloat = 20.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UpdateUserPromptsStackViewController? {
    guard let updateUserPromptsVC = R.storyboard.updateUserPromptsStackViewController
      .instantiateInitialViewController() else { return nil }
    return updateUserPromptsVC
  }

}

// MARK: - Life Cycle
extension UpdateUserPromptsStackViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    self.refreshPrompts()
  }
  
  func refreshPrompts() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to get Pear User")
      return
    }
    self.stackView.arrangedSubviews.forEach({
      $0.removeFromSuperview()
      self.stackView.removeArrangedSubview($0)
    })
    let questionResponses = user.questionResponses.filter({ $0.question.questionType == .freeResponse})
    var index: Int = 0
    if questionResponses.count > 0 {
      print("Count: \(questionResponses.count)")
      for response in questionResponses.filter({ $0.hidden == false}) {
        self.addPromptCard(response: response, index: index)
        index += 1
      }
    } else {
      self.addNoPromptsCard()
    }
  }
  
  func stylize() {
    
  }
  
}

// MARK: - No Prompts
extension UpdateUserPromptsStackViewController {
 
  func addPromptCard(response: QuestionResponseItem, index: Int = 0) {
    let cardInset: CGFloat = 12.0
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let cardView = UIButton()
    cardView.addTarget(self, action: #selector(UpdateUserPromptsStackViewController.replacePromptClicked(sender:)), for: .touchUpInside)
    cardView.tag = index
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.layer.cornerRadius = 12
    cardView.layer.borderWidth = 1.0
    cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    containerView.addSubview(cardView)
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
      ])
    
    let thumbnailImageView = UIImageView()
    thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
    thumbnailImageView.contentMode = .scaleAspectFill
    if let imageURLString = response.authorThumbnailURL,
      let imageURL = URL(string: imageURLString) {
      thumbnailImageView.sd_setImage(with: imageURL, completed: nil)
    } else {
      thumbnailImageView.image = R.image.friendsNoImage()
    }
    let thumbnailSize: CGFloat = 24
    thumbnailImageView.layer.cornerRadius = thumbnailSize / 2.0
    thumbnailImageView.clipsToBounds = true
    thumbnailImageView.addConstraints([
      NSLayoutConstraint(item: thumbnailImageView, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thumbnailSize),
      NSLayoutConstraint(item: thumbnailImageView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: thumbnailSize)
      ])
    cardView.addSubview(thumbnailImageView)
    
    let creatorNameLabel = UILabel()
    creatorNameLabel.translatesAutoresizingMaskIntoConstraints = false
    creatorNameLabel.text = response.authorFirstName
    if let font = R.font.openSansBold(size: 12) {
      creatorNameLabel.font = font
    }
    creatorNameLabel.textColor = R.color.primaryTextColor()
    cardView.addSubview(creatorNameLabel)
    
    // Thumbnail and Creator name constraints
    cardView.addConstraints([
      NSLayoutConstraint(item: thumbnailImageView, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: cardInset),
      NSLayoutConstraint(item: thumbnailImageView, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: cardInset),
      NSLayoutConstraint(item: creatorNameLabel, attribute: .left, relatedBy: .equal,
                         toItem: thumbnailImageView, attribute: .right, multiplier: 1.0, constant: cardInset),
      NSLayoutConstraint(item: creatorNameLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: thumbnailImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    
    let questionLabel = UILabel()
    questionLabel.translatesAutoresizingMaskIntoConstraints = false
    questionLabel.numberOfLines = 0
    questionLabel.text = response.question.questionText
    if let font = R.font.openSansBold(size: 14) {
      questionLabel.font = font
    }
    questionLabel.textColor = R.color.primaryTextColor()
    cardView.addSubview(questionLabel)
    
    cardView.addConstraints([
      NSLayoutConstraint(item: questionLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: cardInset),
      NSLayoutConstraint(item: questionLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -cardInset),
      NSLayoutConstraint(item: questionLabel, attribute: .top, relatedBy: .equal,
                         toItem: thumbnailImageView, attribute: .bottom, multiplier: 1.0, constant: 8.0)
      ])
    
    let responseLabel = UILabel()
    responseLabel.translatesAutoresizingMaskIntoConstraints = false
    responseLabel.numberOfLines = 0
    responseLabel.text = response.responseBody
    if let font = R.font.openSansSemiBold(size: 14) {
      responseLabel.font = font
    }
    responseLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
    cardView.addSubview(responseLabel)
    
    cardView.addConstraints([
      NSLayoutConstraint(item: responseLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: cardInset),
      NSLayoutConstraint(item: responseLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -cardInset),
      NSLayoutConstraint(item: responseLabel, attribute: .top, relatedBy: .equal,
                         toItem: questionLabel, attribute: .bottom, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: responseLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -cardInset)
      ])
    
    let moreButton = UIButton()
    moreButton.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(moreButton)
    
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addNoPromptsCard() {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let cardView = UIButton()
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.backgroundColor = UIColor(red: 1.00, green: 0.93, blue: 0.88, alpha: 1.00)
    cardView.layer.cornerRadius = 12.0
    cardView.addTarget(self, action: #selector(UpdateUserPromptsStackViewController.requestFriendPrompt), for: .touchUpInside)
    containerView.addSubview(cardView)
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
      ])
    
    let imageView = UIImageView()
    imageView.image = R.image.meIconWarning()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil,
                         attribute: .notAnAttribute, multiplier: 1.0, constant: 24),
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView,
                         attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
    cardView.addSubview(imageView)
    let descriptionLabel = UILabel()
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.text =  "To appear in Discovery, you need at least three prompts answered by a friend."
    if let font = R.font.openSansSemiBold(size: 14.0) {
      descriptionLabel.font = font
    }
    descriptionLabel.textColor = R.color.primaryTextColor()
    descriptionLabel.numberOfLines = 0
    cardView.addSubview(descriptionLabel)
    let addFriendLabel = UILabel()
    addFriendLabel.text = "Add a friend"
    if let font = R.font.openSansBold(size: 14.0) {
      addFriendLabel.font = font
    }
    addFriendLabel.textColor = UIColor(red: 1.00, green: 0.56, blue: 0.23, alpha: 1.00)
    addFriendLabel.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(addFriendLabel)
    
    // Relative Constraints
    cardView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal,
                         toItem: imageView, attribute: .right, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal,
                         toItem: addFriendLabel, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: addFriendLabel, attribute: .top, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .right, relatedBy: .equal,
                         toItem: descriptionLabel, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    
    self.stackView.addArrangedSubview(containerView)
  }
  
  @objc func requestFriendPrompt() {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let requestFriendVC = RequestProfileViewController.instantiate() else {
      print("Unable to create request Friend VC")
      return
    }
    self.present(requestFriendVC, animated: true, completion: nil)
  }
  
  @objc func replacePromptClicked(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let promptPickerVC = PromptPickerViewController.instantiate(replaceIndex: sender.tag) else {
      print("Unable to create prompt picker VC")
      return
    }
    promptPickerVC.promptPickerDelegate = self
    self.navigationController?.pushViewController(promptPickerVC, animated: true)
  }
  
}

// MARK: - PromptPickerDelegate
extension UpdateUserPromptsStackViewController: PromptPickerDelegate {
  
  func didReplacePrompt(prompt: QuestionResponseItem, atIndex: Int?) {
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to get pear user")
      return
    }
    if let pickedPromptIndex = user.questionResponses.firstIndex(of: prompt),
      let index = atIndex {
      user.questionResponses.remove(at: pickedPromptIndex)
      user.questionResponses[index].hidden = true
      user.questionResponses.insert(prompt, at: index)
      prompt.hidden = false
    }
    
    PearUpdateUserAPI.shared.updateUserPrompts(prompts: user.questionResponses) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Updated user prompts successfully")
        } else {
           print("Failed to update user prompts")
        }
      case .failure(let error):
        print("Failed to update user prompts: \(error)")
      }
    }
    DispatchQueue.main.async {
      self.refreshPrompts()
    }
  }
  
}
