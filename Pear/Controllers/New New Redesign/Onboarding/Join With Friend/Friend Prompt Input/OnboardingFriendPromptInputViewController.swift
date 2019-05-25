//
//  OnboardingFriendPromptInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ContactsUI
import MessageUI
import FirebaseAnalytics

protocol PromptInputDelegate: class {
  func didAnswerPrompt(questionResponse: QuestionResponseItem)
  func editResponseAtIndex(questionResponse: QuestionResponseItem, index: Int)
  func deleteResponseAtIndex(index: Int)
}

class OnboardingFriendPromptInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var profileData: ProfileCreationData?
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  var friendFirstName: String!
  var friendGender: GenderEnum!
  var answeredPrompts: [QuestionResponseItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(friendFirstName: String, gender: GenderEnum) -> OnboardingFriendPromptInputViewController? {
    guard let friendPromptVC = R.storyboard.onboardingFriendPromptInputViewController()
      .instantiateInitialViewController() as? OnboardingFriendPromptInputViewController else { return nil }
    friendPromptVC.friendFirstName = friendFirstName
    friendPromptVC.friendGender = gender
    return friendPromptVC
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if answeredPrompts.count < 3 {
      let alertController = UIAlertController(title: "You must fill out 3 prompts to continue", message: "You can edit them later", preferredStyle: .alert)
      let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
      alertController.addAction(okayAction)
      self.present(alertController, animated: true, completion: nil)
      return
    }
    self.promptContactsPicker()
  }
  
  func promptMessageComposer() {
    print("****prompting message composer****")
    guard let profileData = self.profileData else {
      print("profile data not found")
      return
    }
    guard let messageVC = self.getMessageComposer(profileData: profileData) else {
      print("Could not create Message VC")
      Analytics.logEvent("CP_sendProfileSMS_FAIL", parameters: nil)
      if let profileData = self.profileData {
        profileData.questionResponses = self.answeredPrompts
      }
      self.createDetachedProfile(profileData: profileData,
                                 completion: self.createDetachedProfileCompletion(result:))
      return
    }
    messageVC.messageComposeDelegate = self
    #if DEVMODE
    if let profileData = self.profileData {
      profileData.questionResponses = self.answeredPrompts
      profileData.firstName = self.friendFirstName
      profileData.gender = self.friendGender
    }
    self.createDetachedProfile(profileData: profileData,
                               completion: self.createDetachedProfileCompletion(result:))
    return
    #endif
    self.present(messageVC, animated: true, completion: nil)
    Analytics.logEvent("CP_sendProfileSMS_START", parameters: nil)
  }
  
}

// MARK: - Life Cycle
extension OnboardingFriendPromptInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.setPreviousPageProgress()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.setCurrentPageProgress(animated: animated)
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
  }
  
  func setup() {
    self.setupStackView()
  }
  
  func setupStackView() {
    var count = 0
    for index in 0..<self.answeredPrompts.count {
      self.addAnsweredPromptButton(response: self.answeredPrompts[index], index: count)
      count += 1
    }
    if self.answeredPrompts.count < 3 {
      for _ in 0..<(3 - self.answeredPrompts.count) {
        self.addPromptButton(number: count + 1, index: count)
        count += 1
      }
    } else {
      self.addAnotherButton()
    }
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
    containerButton.addTarget(self, action: #selector(OnboardingFriendPromptInputViewController.promptResponseActionSheet), for: .touchUpInside)
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
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: promptLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -12.0)
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
      NSLayoutConstraint(item: responseLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: -12.0),
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
    
    self.stackView.addArrangedSubview(containerButton)
  }
  
  func addPromptButton(number: Int? = nil, index: Int) {
    let containerButton = UIButton()
    containerButton.tag = index
    containerButton.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addTarget(self, action: #selector(OnboardingFriendPromptInputViewController.promptResponsePickerVC), for: .touchUpInside)
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
    if let number = number {
      promptLabel.text = "Answer prompt #\(number)"
      promptLabel.textColor = R.color.primaryTextColor()
    } else {
      promptLabel.text = "Add another"
      promptLabel.textColor = UIColor(red: 0.29, green: 0.86, blue: 0.52, alpha: 1.00)
    }
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
    
    self.stackView.addArrangedSubview(containerButton)
  }
  
  func addAnotherButton() {
    let containerButton = UIButton()
    containerButton.translatesAutoresizingMaskIntoConstraints = false
    containerButton.addTarget(self, action: #selector(OnboardingFriendPromptInputViewController.promptResponsePickerVC), for: .touchUpInside)
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
    if index >= self.answeredPrompts.count || index < 0 {
      return
    }
    let questionResponse = self.answeredPrompts[index]
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
  
    guard let promptResponseVC = PromptInputViewController.instantiate(prompts: possiblePrompts, answeredPrompts: self.answeredPrompts) else {
      print("couldn't initialize prompt response VC")
      return
    }
    promptResponseVC.promptInputDelegate = self
    let navigationController = UINavigationController(rootViewController: promptResponseVC)
    navigationController.isNavigationBarHidden = true
    self.present(navigationController, animated: true, completion: nil)
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingFriendPromptInputViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return self.progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 3
  }
  
  var progressBarTotalPages: Int {
    return 3
  }
}

extension OnboardingFriendPromptInputViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
    picker.dismiss(animated: true)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
    picker.dismiss(animated: true)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    self.profileData = creationData
    self.profileData?.firstName = self.friendFirstName
    self.profileData?.gender = self.friendGender
    DispatchQueue.main.async {
      self.promptMessageComposer()
    }
  }
  
  func recievedProfileCreationError(title: String, message: String?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
      self.activityIndicator.stopAnimating()
      self.continueButton.isEnabled = true
    }
  }
  
  func promptContactsPicker() {
    let cnPicker = self.getContactsPicker()
    cnPicker.delegate = self
    
    self.continueButton.isEnabled = false
    self.activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                     type: NVActivityIndicatorType.lineScalePulseOut,
                                                     color: StylingConfig.textFontColor,
                                                     padding: 0)
    self.view.addSubview(activityIndicator)
    activityIndicator.center = CGPoint(x: self.view.center.x,
                                       y: self.continueButton.frame.origin.y - 40)
    activityIndicator.startAnimating()
    self.present(cnPicker, animated: true, completion: nil)
  }
  
  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    self.continueButton.isEnabled = true
    self.activityIndicator.stopAnimating()
    self.activityIndicator.removeFromSuperview()
    print("Cancel Contact Picker")
  }
  
}

// MARK: - MFMessageComposeViewControllerDelegate
extension OnboardingFriendPromptInputViewController: MFMessageComposeViewControllerDelegate {
  func createDetachedProfileCompletion(result: Result<PearDetachedProfile, (errorTitle: String, errorMessage: String)?>) {
    switch result {
    case .success:
      DispatchQueue.main.async {
        guard let basicInfoVC = OnboardingBasicInfoViewController.instantiate() else {
          print("Failed to create basic info VC")
          return
        }
        
        guard var viewControllers = self.navigationController?.viewControllers else {
          print("No view controllers detected")
          return
        }
        viewControllers.popLast()
        viewControllers.popLast()
        viewControllers.popLast()
        viewControllers.append(basicInfoVC)
        self.navigationController?.setViewControllers(viewControllers, animated: true)
      }
    case .failure(let error):
      if let error = error {
        DispatchQueue.main.async {
          self.alert(title: error.errorTitle, message: error.errorMessage)
        }
      }
    }
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
      self.continueButton.isEnabled = true
    }
  }
  
  func dismissMessageVC(controller: MFMessageComposeViewController) {
    controller.dismiss(animated: true) {
      DispatchQueue.main.async {
        self.continueButton.isEnabled = true
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    switch result {
    case .cancelled, .failed:
      self.dismissMessageVC(controller: controller)
    case .sent:
      controller.dismiss(animated: true) {
        if let profileData = self.profileData {
          profileData.questionResponses = self.answeredPrompts
          DispatchQueue.main.async {
            self.createDetachedProfile(profileData: profileData,
                                       completion: self.createDetachedProfileCompletion(result:))
          }
        } else {
          print("couldn't find profile data")
        }
      }
    @unknown default:
      fatalError()
    }
  }
}

// MARK: - PromptSMSProtocol
extension OnboardingFriendPromptInputViewController: PromptSMSProtocol {
  
}

extension OnboardingFriendPromptInputViewController: PermissionsFlowProtocol {
  
}

extension OnboardingFriendPromptInputViewController: PromptInputDelegate {
  func didAnswerPrompt(questionResponse: QuestionResponseItem) {
    self.answeredPrompts.append(questionResponse)
    self.refreshStackView()
  }
  
  func editResponseAtIndex(questionResponse: QuestionResponseItem, index: Int) {
    if index < self.answeredPrompts.count && index >= 0 {
      self.answeredPrompts[index] = questionResponse
      self.refreshStackView()
    }
  }
  
  func deleteResponseAtIndex(index: Int) {
    self.answeredPrompts.remove(at: index)
    self.refreshStackView()
  }
}
