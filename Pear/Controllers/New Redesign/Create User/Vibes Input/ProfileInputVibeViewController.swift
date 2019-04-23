//
//  ProfileInputVibeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInputVibeViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var topSeperatorView: UIView!
  
  var profileData: ProfileCreationData!
  var inputTVC: InputTableViewController?
  var tableViewHeightConstraint: NSLayoutConstraint?
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> ProfileInputVibeViewController? {
    guard let profileVibeVC = R.storyboard.profileInputVibeViewController()
      .instantiateInitialViewController() as? ProfileInputVibeViewController else { return nil }
    profileVibeVC.profileData = profileCreationData
    return profileVibeVC
  }
  
}

// MARK: - Life Cycle
extension ProfileInputVibeViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addCardQuestion(question: QuestionItem.vibeQuestion())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let tableViewHeightConstraint = self.tableViewHeightConstraint, let tableViewHeight = self.inputTVC?.tableViewContentHeight() {
      tableViewHeightConstraint.constant = tableViewHeight
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorOrange()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
  }
  
  func setup() {
    
  }
  
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
    
    guard let inputTVC = InputTableViewController.instantiate(question: question, multiselect: true, vibesInput: true) else {
      print("Failed to create answer TVC")
      return
    }
    self.inputTVC = inputTVC
    inputTVC.delegate = self
    
    self.addChild(inputTVC)
    stackView.addArrangedSubview(inputTVC.view)
    
    inputTVC.didMove(toParent: self)
    
    self.view.addSubview(cardView)
    
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

// MARK: - Vibe Question
extension ProfileInputVibeViewController {
  
}

// MARK: - Input TVDelegate
extension ProfileInputVibeViewController: InputTableViewDelegate {
  func canSelect(response: SuggestedResponseTableItem, allItems: [SuggestedResponseTableItem]) -> Bool {
    let numberSelected = allItems.filter({$0.selected}).count
    return numberSelected <= 2
  }
  
  func suggestedResponseSelected(response: QuestionResponseItem, allItems: [SuggestedResponseTableItem]) {
    
  }
  
}
