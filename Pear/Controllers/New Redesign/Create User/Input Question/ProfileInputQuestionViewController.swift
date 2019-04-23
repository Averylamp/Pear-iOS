//
//  ProfileInputQuestionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInputQuestionViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var topSeperatorView: UIView!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var questionCountLabel: UILabel!
  @IBOutlet weak var questionCountImageView: UIImageView!
  
  var profileData: ProfileCreationData!
  var inputTVC: InputTableViewController?
  var tableViewHeightConstraint: NSLayoutConstraint?
  var question: QuestionItem!
  var alreadySelectedResponse: Bool = false
  var selectedResponse: QuestionResponseItem?
  
  let checkImages: [UIImage?] = [R.image.iconCheckRound(),
                                 R.image.iconCheckPointy(),
                                 R.image.iconCheckRoundish()]
  var questionBackgroundColors: [UIColor?] = [R.color.backgroundColorBlue(),
                                              R.color.backgroundColorPurple(),
                                              R.color.backgroundColorOrange()]
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData, question: QuestionItem) -> ProfileInputQuestionViewController? {
    guard let profileVibeVC = R.storyboard.profileInputQuestionViewController()
      .instantiateInitialViewController() as? ProfileInputQuestionViewController else { return nil }
    profileVibeVC.profileData = profileCreationData
    profileVibeVC.question = question
    return profileVibeVC
  }
  
  func continueToNextQuestion() {
    DispatchQueue.main.async {
      var questionResponse: QuestionResponseItem?
      questionResponse = self.selectedResponse
      if let inputTVC = self.inputTVC,
        let foundResponse = inputTVC.responseItems.filter({ $0.selected }).first?.suggestion,
        foundResponse.responseBody != questionResponse?.responseBody,
        let newResponse = try? QuestionResponseItem(documentID: nil,
                                                    question: inputTVC.question,
                                                    responseBody: foundResponse.responseBody,
                                                    responseTitle: foundResponse.responseTitle,
                                                    color: foundResponse.color,
                                                    icon: foundResponse.icon) {
        questionResponse = newResponse
      }
      
      guard let response = questionResponse else {
        print("No response found")
        return
      }
      self.profileData.questionResponses.append(response)
      guard let nextQuestionVC = ProfileInputQuestionViewController.instantiate(profileCreationData: self.profileData,
                                                                                question: QuestionItem.idealDateQuestion()) else {
                                                                                  print("Failed to create question VC")
                                                                                  return
      }
      self.navigationController?.pushViewController(nextQuestionVC, animated: true)
    }
  }
  
}

// MARK: - Life Cycle
extension ProfileInputQuestionViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let tableViewHeightConstraint = self.tableViewHeightConstraint, let tableViewHeight = self.inputTVC?.tableViewContentHeight() {
      tableViewHeightConstraint.constant = tableViewHeight
    }
  }
  
  func stylize() {
    
    self.view.backgroundColor = questionBackgroundColors[self.profileData.questionResponses.count % questionBackgroundColors.count]
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    self.nextButton.layer.cornerRadius = self.nextButton.frame.width / 2.0
    self.nextButton.alpha = 0.0
    self.nextButton.isUserInteractionEnabled = false
    self.questionCountLabel.text = "\(self.profileData.questionResponses.count + 1)"
    self.questionCountImageView.contentMode = .scaleAspectFill
    self.questionCountImageView.image = self.checkImages[self.profileData.questionResponses.count % checkImages.count]
  }
  
  func setup() {
    self.addCardQuestion(question: self.question)
  }
  
}

// MARK: - Question Card Setup
extension ProfileInputQuestionViewController {
  
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
    
    let titleView = self.createTitleLabelForCard(title: question.questionText)
    stackView.addArrangedSubview(titleView)
    if let subtitleText = question.questionSubtext {
      let subtitleView = self.createSubtitleLabel(subtitle: subtitleText)
      stackView.addArrangedSubview(subtitleView)
    }
    
    guard let inputTVC = InputTableViewController.instantiate(question: question) else {
      print("Failed to create answer TVC")
      return
    }
    self.inputTVC = inputTVC
    inputTVC.delegate = self
    
    self.addChild(inputTVC)
    stackView.addArrangedSubview(inputTVC.view)
    
    inputTVC.didMove(toParent: self)
    
    self.view.insertSubview(cardView, belowSubview: self.nextButton)
    
    let topConstraint = NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .greaterThanOrEqual,
                                           toItem: self.topSeperatorView, attribute: .top, multiplier: 1.0, constant: 20.0)
    topConstraint.priority = .defaultHigh
    let bottomConstraint = NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .lessThanOrEqual,
                                              toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20.0)
    bottomConstraint.priority = .defaultHigh
    self.view.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .centerY, relatedBy: .equal,
                         toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: self.topSeperatorView.center.y / 2.0),
      NSLayoutConstraint(item: cardView, attribute: .width, relatedBy: .equal,
                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: -40),
      topConstraint,
      bottomConstraint
      ])
    
    self.view.layoutIfNeeded()
    let tableViewHeightConstraint = NSLayoutConstraint(item: inputTVC.view as Any, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: inputTVC.tableViewContentHeight())
    tableViewHeightConstraint.priority = .defaultLow
    inputTVC.view.addConstraint(tableViewHeightConstraint)
    self.tableViewHeightConstraint = tableViewHeightConstraint
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
  
}

// MARK: - InputTVDelegate
extension ProfileInputQuestionViewController: InputTableViewDelegate {
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
      checkboxImage.image = self.checkImages[self.profileData.questionResponses.count % self.checkImages.count]

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
      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
        checkboxImage.alpha = 1.0
      }, completion: { (_) in
        self.delay(delay: 0.8, closure: {
          self.continueToNextQuestion()
        })
      })
      
    }
  }
  
}
