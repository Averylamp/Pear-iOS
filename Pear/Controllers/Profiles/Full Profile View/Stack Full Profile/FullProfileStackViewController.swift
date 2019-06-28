//
//  FullProfileStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileStackViewController: UIViewController {
  
  var fullProfileData: FullProfileDisplayData!
  
  @IBOutlet var stackView: UIStackView!
  
  static let backgroundColor: UIColor? = R.color.cardBackgroundColor()
  static let cardEdgeSpacing: CGFloat = 12.0
  static let cardBetweenSpacing: CGFloat = 12.0
  var sectionItemsWithVCs: [SectionItemWithVC] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(userFullProfileData: FullProfileDisplayData) -> FullProfileStackViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileStackViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? FullProfileStackViewController else { return nil }
    profileStackViewVC.fullProfileData = userFullProfileData
    return profileStackViewVC
  }
  
}

enum SectionType {
  case image
  case demographics
  case question
}

struct SectionItem {
  let sectionType: SectionType
  let image: ImageContainer?
  let demographics: FullProfileDisplayData?
  let question: QuestionResponseItem?
}

struct SectionItemWithVC {
  let sectionItem: SectionItem
  let viewController: UIViewController
}

// MARK: - Life Cycle
extension FullProfileStackViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  static func sectionItemsFromProfile(profile: FullProfileDisplayData) -> [SectionItem] {
    var images = profile.imageContainers
    var questionResponses: [QuestionResponseItem] = profile.questionResponses.filter({ !$0.hidden && $0.question.questionType == .freeResponse})
      .compactMap({ $0.copy() as? QuestionResponseItem })
    var demographics: [FullProfileDisplayData] = [profile]
    var sectionItems: [SectionItem] = []
    var questionResponseCount: Int = 0
    while true {
      var addedItems = false
      if images.count > 0 {
        let image = images.removeFirst()
        sectionItems.append(SectionItem(sectionType: .image, image: image, demographics: nil, question: nil))
        addedItems = true
      }
      if demographics.count > 0 {
        let demographic = demographics.removeFirst()
        sectionItems.append(SectionItem(sectionType: .demographics, image: nil, demographics: demographic, question: nil))
        addedItems = true
      }
     if questionResponses.count > 0 && questionResponseCount < 5 {
        questionResponseCount += 1
        let questionResponse = questionResponses.removeFirst()
        sectionItems.append(SectionItem(sectionType: .question, image: nil, demographics: nil, question: questionResponse))
        addedItems = true
      }
      if !addedItems {
        break
      }
    }
    return sectionItems
  }
  
  func stylize() {
    self.view.backgroundColor = FullProfileStackViewController.backgroundColor
    self.stackView.backgroundColor = FullProfileStackViewController.backgroundColor
  }
  
  func setup() {
    self.addSpacerView(height: 10)
    self.addNameAge(name: self.fullProfileData.firstName ?? "Name Hidden",
                    age: self.fullProfileData.age)
    self.addSpacerView(height: 10)
    
    let sectionItems = FullProfileStackViewController.sectionItemsFromProfile(profile: self.fullProfileData)
    for sectionItem in sectionItems {
      switch sectionItem.sectionType {
      case .image:
        if let image = sectionItem.image {
          let imageVC = self.addImageVC(imageContainer: image)
          if let imageVC = imageVC {
            self.sectionItemsWithVCs.append(SectionItemWithVC(sectionItem: sectionItem, viewController: imageVC))
          }
        }
      case .demographics:
        if let displayData = sectionItem.demographics {
          self.addDemographicsVC(locationName: displayData.locationName,
                                 schoolName: displayData.school,
                                 schoolYear: displayData.schoolYear)
        }
      case .question:
        if let questionItem = sectionItem.question {
          let questionResponseVC = self.addQuestionResponseItem(responseItem: questionItem)
          if let questionResponseVC = questionResponseVC {
            self.sectionItemsWithVCs.append(SectionItemWithVC(sectionItem: sectionItem, viewController: questionResponseVC))
          }
        }
      }
    }
    self.addSpacerView(height: 100)
  }
  
  func addNameAge(name: String, age: Int?) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = FullProfileStackViewController.backgroundColor
    let nameLabel = UILabel()
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansExtraBold(size: 24) {
      nameLabel.font = font
    }
    nameLabel.text = name
    if let age = age {
      nameLabel.text = "\(name), \(age)"
    }
    nameLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
    nameLabel.adjustsFontSizeToFitWidth = true
    nameLabel.minimumScaleFactor  = 0.5
    containerView.addSubview(nameLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: nameLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: nameLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0),
      NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: nameLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addSpacerView(height: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = FullProfileStackViewController.backgroundColor
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.stackView.addArrangedSubview(spacer)
  }
  
  static func addVCToContainer(view: UIView) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = FullProfileStackViewController.backgroundColor
    let cardView = addVCToCard(view: view)
    let cardShadowView = UIView()
    cardShadowView.translatesAutoresizingMaskIntoConstraints = false
    cardShadowView.layer.cornerRadius = 12
    cardShadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    cardShadowView.layer.shadowColor = UIColor(white: 0.2, alpha: 0.05).cgColor
    cardShadowView.layer.shadowOpacity = 1.0
    cardShadowView.layer.shadowRadius = 8.0
    containerView.addSubview(cardShadowView)
    containerView.addSubview(cardView)
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: cardBetweenSpacing / 2.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -cardBetweenSpacing / 2.0),
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: cardEdgeSpacing),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -cardEdgeSpacing)
      ])
    return containerView
  }
  
  static func addVCToCard(view: UIView) -> UIView {
    let cardView = UIView()
    cardView.backgroundColor = UIColor.white
    cardView.layer.cornerRadius = 12
    cardView.clipsToBounds = true
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(view)
    cardView.addConstraints([
      NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    return cardView
  }
  
  @discardableResult func addImageVC(imageContainer: ImageContainer) -> ProfileImageViewController? {
    guard let imageVC = ProfileImageViewController.instantiate(imageContainer: imageContainer) else {
      print("Failed to create Image VC")
      return nil
    }
    self.addChild(imageVC)
    imageVC.view.translatesAutoresizingMaskIntoConstraints = false
    let containerView = FullProfileStackViewController.addVCToContainer(view: imageVC.view)
    self.stackView.addArrangedSubview(containerView)
    imageVC.didMove(toParent: self)
    return imageVC
  }
  
  func addDemographicsVC(locationName: String?,
                         schoolName: String?,
                         schoolYear: String?) {
    guard let demographicsVC = NewProfileDemographicsViewController.instantiate(locationName: locationName,
                                                                                schoolName: schoolName,
                                                                                schoolYear: schoolYear) else {
                                                                                  print("Failed to create Demogrpahics VC")
                                                                                  return
    }
    self.addChild(demographicsVC)
    demographicsVC.view.translatesAutoresizingMaskIntoConstraints = false
    let containerView = FullProfileStackViewController.addVCToContainer(view: demographicsVC.view)
    self.stackView.addArrangedSubview(containerView)
    demographicsVC.didMove(toParent: self)
  }
  
  @discardableResult func addQuestionResponseItem(responseItem: QuestionResponseItem) -> ProfileQuestionResponseViewController? {
    guard let questionItemVC = ProfileQuestionResponseViewController.instantiate(questionItem: responseItem) else {
      print("Failed to instantiate Question Response ItemVC")
      return nil
    }
    self.addChild(questionItemVC)
    questionItemVC.view.translatesAutoresizingMaskIntoConstraints = false
    let containerView = FullProfileStackViewController.addVCToContainer(view: questionItemVC.view)
    self.stackView.addArrangedSubview(containerView)
    questionItemVC.didMove(toParent: self)
    return questionItemVC
  }
  
  func addInterestsVC(interests: [String]) {
    guard let interestsVC = ProfileInterestsViewController.instantiate(interests: interests) else {
      print("Failed to create Interests VC")
      return
    }
    self.addChild(interestsVC)
    self.stackView.addArrangedSubview(interestsVC.view)
    interestsVC.didMove(toParent: self)
    if interests.count == 0 {
      interestsVC.view.isHidden = true
    } else {
      interestsVC.view.isHidden = false
    }
  }
  
}
