//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendEditProfileViewController: UIViewController {
    
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  
  var updateProfileData: UpdateProfileData!
  var firstName: String!
  let leadingSpace: CGFloat = 12
  var isUpdating: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(updateProfileData: UpdateProfileData,
                         firstName: String) -> FriendEditProfileViewController? {
    guard let editFriendVC = R.storyboard.friendEditProfileViewController
      .instantiateInitialViewController() else { return nil }
    editFriendVC.updateProfileData = updateProfileData
    editFriendVC.firstName = firstName
    return editFriendVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    if self.updateProfileData.checkForChanges() {
      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .warning)
      let alertController = UIAlertController(title: "Are you sure?",
                                              message: "Your unsaved changes will be lost.",
                                              preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let goBackAction = UIAlertAction(title: "Don't Save", style: .destructive) { (_) in
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }
      }
      alertController.addAction(goBackAction)
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil) 
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    self.updateProfileData.saveChanges { (success) in
      if success {
        DispatchQueue.main.async {
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
          DataStore.shared.refreshEndorsedUsers(completion: nil)
          self.navigationController?.popToRootViewController(animated: true)
        }
      } else {
        print("Error saving data")
        DispatchQueue.main.async {
          self.alert(title: "Failure saving data", message: "This issue has been reported and we are working to fix it :)")
        }
      }
    }
    
  }
  
}

// MARK: - Updating and Saving
extension FriendEditProfileViewController {
  
}

// MARK: - Life Cycle
extension FriendEditProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = "Edit \(firstName!)'s Profile"
    self.doneButton.stylizeOnboardingContinueButton()
  }
  
  func setup() {
    self.setupStackView()
  }
  
  func setupStackView() {
    for index in 0..<self.updateProfileData.updatedQuestionResponses.count {
      self.addAnsweredPromptButton(response: self.updateProfileData.updatedQuestionResponses[index], index: index)
    }
    self.addAnotherButton()
  }
  
  func refreshStackView() {
    self.stackView.subviews.forEach {
      self.stackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    self.setupStackView()
  }
  
  func addAnsweredPromptButton(response: QuestionResponseItem, index: Int) {
    let containerButton = UIButton()
    containerButton.tag = index
    containerButton.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addTarget(self, action: #selector(FriendEditProfileViewController.promptResponseActionSheet), for: .touchUpInside)
    let cardView = UIView()
    cardView.isUserInteractionEnabled = false
    cardView.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addSubview(cardView)
    cardView.layer.cornerRadius = 12
    cardView.layer.borderWidth = 2.0
    cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
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
    
    self.stackView.addArrangedSubview(containerButton)
  }
  
  func addAnotherButton() {
    let containerButton = UIButton()
    containerButton.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addTarget(self, action: #selector(FriendEditProfileViewController.promptResponsePickerVC), for: .touchUpInside)
    let cardView = UIView()
    cardView.isUserInteractionEnabled = false
    cardView.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addSubview(cardView)
    cardView.layer.cornerRadius = 12
    cardView.layer.borderWidth = 2.0
    cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
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
    if let font = R.font.openSansBold(size: 18.0) {
      promptLabel.font = font
    }
    
    promptLabel.text = "Add another"
    promptLabel.textAlignment = .center
    promptLabel.textColor = R.color.primaryBrandColor()
    
    promptLabel.addConstraint(NSLayoutConstraint(item: promptLabel, attribute: .height, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
    cardView.addSubview(promptLabel)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptLabel, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: promptLabel, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: promptLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: promptLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -12.0)
      ])
    
    self.stackView.addArrangedSubview(containerButton)
  }
  
  @objc func promptResponseActionSheet(_ sender: UIButton) {
    print("tapped answered response")
    let index = sender.tag
    if index >= self.updateProfileData.updatedQuestionResponses.count || index < 0 {
      return
    }
    let questionResponse = self.updateProfileData.updatedQuestionResponses[index]
    let actionSheet = UIAlertController(title: nil,
                                        message: nil,
                                        preferredStyle: .actionSheet)
    let editResponseAction = UIAlertAction(title: "Edit Response", style: .default) { (_) in
      DispatchQueue.main.async {
        print("tapped edit response")
        guard let promptInputResponseVC = PromptInputResponseViewController.instantiate(question: questionResponse.question,
                                                                                        editMode: true,
                                                                                        previousResponse: questionResponse,
                                                                                        index: index) else {
                                                                                          print("couldn't initialize prompt input response VC")
                                                                                          return
        }
        promptInputResponseVC.promptInputDelegate = self
        let navigationController = UINavigationController(rootViewController: promptInputResponseVC)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true, completion: nil)
      }
    }
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
      DispatchQueue.main.async {
        self.deleteResponseAtIndex(index: index)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(editResponseAction)
    actionSheet.addAction(deleteAction)
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true, completion: nil)
    return
  }
  
  @objc func promptResponsePickerVC() {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let possiblePrompts = DataStore.shared.possibleQuestions.filter {
      return $0.questionType == .freeResponse
    }
    
    guard let promptResponseVC = PromptInputViewController.instantiate(prompts: possiblePrompts, answeredPrompts: self.updateProfileData.updatedQuestionResponses) else {
      print("couldn't initialize prompt response VC")
      return
    }
    promptResponseVC.promptInputDelegate = self
    let navigationController = UINavigationController(rootViewController: promptResponseVC)
    navigationController.isNavigationBarHidden = true
    self.present(navigationController, animated: true, completion: nil)
  }
  
}

// MARK: - PromptInputDelegate
extension FriendEditProfileViewController: PromptInputDelegate {
  func didAnswerPrompt(questionResponse: QuestionResponseItem) {
    self.updateProfileData.updatedQuestionResponses.append(questionResponse)
    self.refreshStackView()
  }
  
  func editResponseAtIndex(questionResponse: QuestionResponseItem, index: Int) {
    if index < self.updateProfileData.updatedQuestionResponses.count && index >= 0 {
      self.updateProfileData.updatedQuestionResponses[index] = questionResponse
      self.refreshStackView()
    }
  }
  
  func deleteResponseAtIndex(index: Int) {
    self.updateProfileData.updatedQuestionResponses.remove(at: index)
    self.refreshStackView()
  }
}
