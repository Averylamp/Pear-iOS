//
//  ApproveProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveProfileViewController: UIViewController {

  @IBOutlet weak var stackView: UIStackView!
  var profileData: FullProfileDisplayData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileData: FullProfileDisplayData) -> ApproveProfileViewController? {
    guard let profileStackViewVC = R.storyboard.approveProfileViewController()
      .instantiateInitialViewController() as? ApproveProfileViewController else { return nil }
    profileStackViewVC.profileData = profileData
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ApproveProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func setup() {
    let sectionItems = FullProfileStackViewController.sectionItemsFromProfile(profile: self.profileData)
    for sectionItem in sectionItems {
      switch sectionItem.sectionType {
      case .image:
        break
      case .textItems:
        if let textItems = sectionItem.textItems {
          if sectionItem.textItems is [BioItem]? {
            self.addSectionTitle(title: "BIOS", backgroundColor: R.color.backgroundColorBlue())
          } else if sectionItem.textItems is [BoastItem]? {
            self.addSectionTitle(title: "BOASTS", backgroundColor: R.color.backgroundColorOrange())
          } else if sectionItem.textItems is [RoastItem]? {
            self.addSectionTitle(title: "ROASTS", backgroundColor: R.color.backgroundColorRed())
          }
          self.addScrollableTextContent(content: textItems)
        }
      case .questions:
        if let questionItems = sectionItem.question {
          self.addSectionTitle(title: "Q&A", backgroundColor: R.color.backgroundColorYellow())
          self.addScrollableQuestionContent(content: questionItems)
        }
      }
    }
  }
  
  func addScrollableTextContent(content: [TextContentItem]) {
    guard let scrollableContentVC = ScrollableTextItemViewController.instantiate(items: content) else {
      print("failed to instantiate scrollable text item")
      return
    }
    self.addChild(scrollableContentVC)
    self.stackView.addArrangedSubview(scrollableContentVC.view)
    scrollableContentVC.didMove(toParent: self)
    
  }
  
  func addScrollableQuestionContent(content: [QuestionResponseItem]) {
    guard let scrollableContentVC = ScrollableQuestionItemViewController.instantiate(items: content) else {
      print("failed to instantiate scrollable questions item")
      return
    }
    self.addChild(scrollableContentVC)
    self.stackView.addArrangedSubview(scrollableContentVC.view)
    scrollableContentVC.didMove(toParent: self)
  }
  
  func addSectionTitle(title: String, backgroundColor: UIColor?) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = backgroundColor
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(titleLabel)
    if let font = R.font.openSansExtraBold(size: 16) {
      titleLabel.font = font
    }
    titleLabel.text = title
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
      ])
    self.stackView.addArrangedSubview(containerView)
  }
  
}
