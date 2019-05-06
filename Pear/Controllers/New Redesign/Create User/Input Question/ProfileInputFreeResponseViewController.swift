//
//  ProfileInputFreeResponseViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/30/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ProfileInputFreeResponseViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var questionCountLabel: UILabel!
  @IBOutlet weak var questionCountImageView: UIImageView!
  @IBOutlet weak var skipContainerView: UIView!
  
  var profileData: ProfileCreationData!
  var freeResponseVC: ExpandingFreeResponseInputViewController?
  var question: QuestionItem!
  var alreadySelectedResponse: Bool = false
  var selectedResponse: QuestionResponseItem?
  var cardBottomConstraint: NSLayoutConstraint?
  
  let checkImages: [UIImage?] = [R.image.iconCheckRound(),
                                 R.image.iconCheckPointy(),
                                 R.image.iconCheckRoundish()]
  var questionBackgroundColors: [UIColor?] = [R.color.backgroundColorBlue(),
                                              R.color.backgroundColorPurple(),
                                              R.color.backgroundColorOrange()]
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData, question: QuestionItem) -> ProfileInputFreeResponseViewController? {
    guard let profileVibeVC = R.storyboard.profileInputFreeResponseViewController()
      .instantiateInitialViewController() as? ProfileInputFreeResponseViewController else { return nil }
    profileVibeVC.profileData = profileCreationData
    profileVibeVC.question = question
    
    return profileVibeVC
  }
  
  func continueToNextQuestion() {
    DispatchQueue.main.async {
      var questionResponse: QuestionResponseItem?
      questionResponse = self.selectedResponse
      if let freeResponseVC = self.freeResponseVC,
        let foundResponse = freeResponseVC.getResponse(),
        let newResponse = try? QuestionResponseItem(documentID: nil,
                                                    question: self.question,
                                                    responseBody: foundResponse,
                                                    responseTitle: nil,
                                                    color: nil,
                                                    icon: nil) {
        questionResponse = newResponse
      }
      
      guard let response = questionResponse else {
        print("No response found")
        return
      }
      self.profileData.questionResponses.append(response)
      guard let nextQuestion = self.profileData.getRandomNextQuestion() else {
        print("Unable to get next question")
        self.continueToRoastBoast()
        return
      }
      self.goToNextQuestion(nextQuestion: nextQuestion)
    }
  }
  
  func goToNextQuestion(nextQuestion: QuestionItem ) {
    if nextQuestion.questionType == .multipleChoice || nextQuestion.questionType == .multipleChoiceWithOther {
      guard let nextQuestionVC = ProfileInputQuestionViewController.instantiate(profileCreationData: self.profileData,
                                                                                question: nextQuestion) else {
                                                                                  print("Failed to create question VC")
                                                                                  return
      }
      self.navigationController?.pushViewController(nextQuestionVC, animated: true)
      Analytics.logEvent("CP_Qs_EV_answeredQ", parameters: nil)
    } else {
      guard let nextQuestionVC = ProfileInputFreeResponseViewController.instantiate(profileCreationData: self.profileData,
                                                                                    question: nextQuestion) else {
                                                                                      print("Failed to create question VC")
                                                                                      return
      }
      self.navigationController?.pushViewController(nextQuestionVC, animated: true)
      Analytics.logEvent("CP_Qs_EV_answeredQ", parameters: nil)
    }
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.profileData.skipCount += 1
    guard let nextQuestion = self.profileData.getRandomNextQuestion() else {
      print("Unable to get next question")
      self.continueToRoastBoast()
      return
    }
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.goToNextQuestion(nextQuestion: nextQuestion)
    Analytics.logEvent("CP_Qs_EV_skippedQ", parameters: nil)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    Analytics.logEvent("CP_Qs_TAP_continueToRoastBoast", parameters: nil)
    self.continueToNextQuestion()
  }
  
  func continueToRoastBoast() {
    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
    guard let boastRoastVC = ProfileInputBoastRoastViewController.instantiate(profileCreationData: self.profileData) else {
      print("Failed to create question VC")
      return
    }
    self.navigationController?.pushViewController(boastRoastVC, animated: true)
    Analytics.logEvent("CP_Qs_DONE", parameters: nil)
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Delete profile?", message: "Your progress will not be saved", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
      DispatchQueue.main.async {
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
    alertController.addAction(alertAction)
    alertController.addAction(deleteAction)
    self.present(alertController, animated: true, completion: nil)  }
}

// MARK: - Life Cycle
extension ProfileInputFreeResponseViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Answering question: \(String(describing: self.question))")
    self.stylize()
    self.setup()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    if let tableViewHeightConstraint = self.tableViewHeightConstraint, let tableViewHeight = self.inputTVC?.tableViewContentHeight() {
//      tableViewHeightConstraint.constant = tableViewHeight
//    }
  }
  
  func stylize() {
    
    self.view.backgroundColor = questionBackgroundColors[(self.profileData.questionResponses.count + self.profileData.skipCount)
      % questionBackgroundColors.count]
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    self.questionCountLabel.text = "\(self.profileData.questionResponses.count + 1)/7"
    self.questionCountImageView.contentMode = .scaleAspectFill
    self.questionCountImageView.image = self.checkImages[(self.profileData.questionResponses.count + self.profileData.skipCount)
      % checkImages.count]
    if self.profileData.questionResponses.count == 0 {
      self.skipContainerView.alpha = 0.0
      UIView.animate(withDuration: 0.8, delay: 5.0, options: .curveEaseInOut, animations: {
        self.skipContainerView.alpha = 1.0
      }, completion: nil)
    }
  }
  
  func setup() {
    self.addCardQuestion(question: self.question)
  }
  
}

// MARK: - Question Card Setup
extension ProfileInputFreeResponseViewController {
  
  func addCardQuestion(question: QuestionItem) {
    let cardView = UIView()
    cardView.backgroundColor = UIColor.white
    cardView.layer.cornerRadius = 12
    cardView.layer.shadowOpacity = 0.2
    cardView.layer.shadowRadius = 2
    cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
    cardView.layer.shadowColor = UIColor.black.cgColor
    cardView.translatesAutoresizingMaskIntoConstraints = false
    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    cardView.addSubview(stackView)
    cardView.addConstraints([
      NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal,
                         toItem: cardView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal,
                         toItem: cardView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal,
                         toItem: cardView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal,
                         toItem: cardView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
    var titleText = question.questionText
    if let textWithName = question.questionTextWithName {
      titleText = textWithName.replacingOccurrences(of: "{{name}}", with: self.profileData.firstName)
    }
    
    let titleView = self.createTitleLabelForCard(title: titleText)
    stackView.addArrangedSubview(titleView)
    if let subtitleText = question.questionSubtext {
      let subtitleView = self.createSubtitleLabel(subtitle: subtitleText)
      stackView.addArrangedSubview(subtitleView)
    }
    
    guard let expandingFreeResponseVC = ExpandingFreeResponseInputViewController.instantiate(placeholderText: question.placeholderResponseText) else {
                                                                            print("Failed to create expanding Text VC")
                                                                            return
    }
    self.freeResponseVC = expandingFreeResponseVC
    self.addChild(expandingFreeResponseVC)
    stackView.addArrangedSubview(expandingFreeResponseVC.view)
    expandingFreeResponseVC.didMove(toParent: self)
        
    self.view.addSubview(cardView)
    
    let topConstraint = NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .greaterThanOrEqual,
                                           toItem: self.skipContainerView, attribute: .bottom, multiplier: 1.0, constant: 10.0)
    topConstraint.priority = UILayoutPriority(rawValue: 500)
    let bottomConstraint = NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .lessThanOrEqual,
                                              toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10.0)
    bottomConstraint.priority = .defaultHigh
    self.cardBottomConstraint = bottomConstraint
    let centerYConstraint = NSLayoutConstraint(item: cardView, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: -10.0)
    centerYConstraint.priority = .defaultLow
    self.view.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .width, relatedBy: .equal,
                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: -40),
      centerYConstraint,
      topConstraint,
      bottomConstraint
      ])
    
    let continueButton = self.createContinueButton()
    stackView.addArrangedSubview(continueButton)

    self.view.layoutIfNeeded()
  }
  
  func createTitleLabelForCard(title: String) -> UIView {
    let titleContainerView = UIView()
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.numberOfLines = 0
    if let font = R.font.openSansExtraBold(size: 24) {
      titleLabel.font = font
    }
    titleLabel.text = title
    titleContainerView.addSubview(titleLabel)
    titleContainerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: titleContainerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: titleContainerView, attribute: .bottom, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: titleContainerView, attribute: .left, multiplier: 1.0, constant: 16.0),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: titleContainerView, attribute: .right, multiplier: 1.0, constant: -16.0)
      ])
    
    return titleContainerView
  }
  
  func createSubtitleLabel(subtitle: String) -> UIView {
    let subtitleContainerView = UIView()
    subtitleContainerView.translatesAutoresizingMaskIntoConstraints = false
    let subtitleLabel = UILabel()
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.numberOfLines = 0
    if let font = R.font.openSansExtraBold(size: 16) {
      subtitleLabel.font = font
    }
    subtitleLabel.textColor = UIColor(white: 0.0, alpha: 0.3)
    subtitleLabel.text = subtitle
    subtitleContainerView.addSubview(subtitleLabel)
    subtitleContainerView.addConstraints([
      NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal,
                         toItem: subtitleContainerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: subtitleContainerView, attribute: .bottom, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: subtitleLabel, attribute: .left, relatedBy: .equal,
                         toItem: subtitleContainerView, attribute: .left, multiplier: 1.0, constant: 16.0),
      NSLayoutConstraint(item: subtitleLabel, attribute: .right, relatedBy: .equal,
                         toItem: subtitleContainerView, attribute: .right, multiplier: 1.0, constant: -16.0)
      ])
    
    return subtitleContainerView
  }
  
  func createContinueButton() -> UIView {
    let buttonContainerView = UIView()
    buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
    let continueButton = UIButton()
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 18) {
      continueButton.titleLabel?.font = font
    }
    continueButton.backgroundColor = R.color.backgroundColorYellow()
    continueButton.setTitle("Continue", for: .normal)
    continueButton.setTitleColor(UIColor.black, for: .normal)
    continueButton.addTarget(self, action: #selector(ProfileInputFreeResponseViewController.continueButtonClicked(_:)), for: .touchUpInside)
    continueButton.addConstraint(NSLayoutConstraint(item: continueButton, attribute: .height, relatedBy: .equal,
                                                    toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
    continueButton.layer.cornerRadius = 25.0
    buttonContainerView.addSubview(continueButton)
    buttonContainerView.addConstraints([
      NSLayoutConstraint(item: continueButton, attribute: .top, relatedBy: .equal,
                         toItem: buttonContainerView, attribute: .top, multiplier: 1.0, constant: 16.0),
      NSLayoutConstraint(item: continueButton, attribute: .bottom, relatedBy: .equal,
                         toItem: buttonContainerView, attribute: .bottom, multiplier: 1.0, constant: -16.0),
      NSLayoutConstraint(item: continueButton, attribute: .left, relatedBy: .equal,
                         toItem: buttonContainerView, attribute: .left, multiplier: 1.0, constant: 16.0),
      NSLayoutConstraint(item: continueButton, attribute: .right, relatedBy: .equal,
                         toItem: buttonContainerView, attribute: .right, multiplier: 1.0, constant: -16.0)
      ])
    
    return buttonContainerView
  }
  
}

// MARK: - InputTVDelegate
extension ProfileInputFreeResponseViewController: InputTableViewDelegate {
  func canSelect(response: SuggestedResponseTableItem, allItems: [SuggestedResponseTableItem]) -> Bool {
    let numberSelected = allItems.filter({$0.selected}).count
    return numberSelected <= 2
  }
  
  func suggestedResponseSelected(response: QuestionResponseItem, allItems: [SuggestedResponseTableItem]) {
    guard !self.alreadySelectedResponse else {
      print("Already selected response")
      return
    }
    self.alreadySelectedResponse = true
    self.selectedResponse = response
    
    DispatchQueue.main.async {
      
      let checkboxImage = UIImageView()
      checkboxImage.contentMode = .scaleAspectFill
      checkboxImage.image = self.checkImages[(self.profileData.questionResponses.count + self.profileData.skipCount)
        % self.checkImages.count]
      
      checkboxImage.alpha = 0.0
      checkboxImage.translatesAutoresizingMaskIntoConstraints = false
      checkboxImage.addConstraints([
        NSLayoutConstraint(item: checkboxImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200),
        NSLayoutConstraint(item: checkboxImage, attribute: .width, relatedBy: .equal, toItem: checkboxImage, attribute: .height, multiplier: 1.0, constant: 0)
        ])
      self.view.addSubview(checkboxImage)
      self.view.addConstraints([
        NSLayoutConstraint(item: checkboxImage, attribute: .centerX, relatedBy: .equal,
                           toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: checkboxImage, attribute: .centerY, relatedBy: .equal,
                           toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
        ])
      UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
        checkboxImage.alpha = 1.0
      }, completion: { (_) in
        self.delay(delay: 0.3, closure: {
          self.continueToNextQuestion()
        })
      })
    }
  }
  
}

// MARK: - Keybaord Size Notifications
extension ProfileInputFreeResponseViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ProfileInputFreeResponseViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ProfileInputFreeResponseViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      if let cardBottomConstraint = self.cardBottomConstraint {
        cardBottomConstraint.constant = 0 - (targetFrame.height - self.view.safeAreaInsets.bottom + 40)
      }
      
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      if let cardBottomConstraint = self.cardBottomConstraint {
        cardBottomConstraint.constant = -20
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}

// MARK: - Dismiss First Responder on Click
extension ProfileInputFreeResponseViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInputFreeResponseViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
