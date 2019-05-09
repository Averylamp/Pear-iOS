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
  
  let backgroundColor: UIColor = UIColor(white: 0.94, alpha: 1.0)
  let cardEdgeSpacing: CGFloat = 12.0
  let cardBetweenSpacing: CGFloat = 12.0
  
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
  case bio
  case question
}

struct SectionItem {
  let sectionType: SectionType
  let image: ImageContainer?
  let demographics: FullProfileDisplayData?
  let bio: BioItem?
  let question: QuestionResponseItem?
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
    var bioItems: [BioItem] = profile.bios.filter({ !$0.hidden}).compactMap({ $0.copy() as? BioItem })
    var questionResponses: [QuestionResponseItem] = profile.questionResponses.filter({ !$0.hidden && $0.question.questionType == .freeResponse})
      .compactMap({ $0.copy() as? QuestionResponseItem })
    var demographics: [FullProfileDisplayData] = [profile]
    var sectionItems: [SectionItem] = []
    while true {
      var addedItems = false
      if images.count > 0 {
        let image = images.removeFirst()
        sectionItems.append(SectionItem(sectionType: .image, image: image, demographics: nil, bio: nil, question: nil))
        addedItems = true
      }
      if demographics.count > 0 {
        let demographic = demographics.removeFirst()
        sectionItems.append(SectionItem(sectionType: .demographics, image: nil, demographics: demographic, bio: nil, question: nil))
        addedItems = true
      }
      if bioItems.count > 0 {
        let bioItem = bioItems.removeFirst()
        sectionItems.append(SectionItem(sectionType: .bio, image: nil, demographics: nil, bio: bioItem, question: nil))
        addedItems = true
      } else if questionResponses.count > 0 {
        let questionResponse = questionResponses.removeFirst()
        sectionItems.append(SectionItem(sectionType: .question, image: nil, demographics: nil, bio: nil, question: questionResponse))
        addedItems = true
      }
      if !addedItems {
        break
      }
    }
    return sectionItems
  }
  
  func stylize() {
    self.view.backgroundColor = self.backgroundColor
    self.stackView.backgroundColor = self.backgroundColor
  }
  
  func setup() {
    self.addSpacerView(height: 10)
    self.addNameAge(name: self.fullProfileData.firstName ?? "¯\\_(ツ)_/¯",
                    age: self.fullProfileData.age)
    self.addSpacerView(height: 10)
    //    self.addDemographcsVC(firstName: self.fullProfileData.firstName,
    //                          age: self.fullProfileData.age,
    //                          schoolName: self.fullProfileData.school,
    //                          locationName: self.fullProfileData.locationName,
    //                          vibes: self.fullProfileData.vibes)
    
    let sectionItems = FullProfileStackViewController.sectionItemsFromProfile(profile: self.fullProfileData)
    for sectionItem in sectionItems {
      switch sectionItem.sectionType {
      case .image:
        if let image = sectionItem.image {
          self.addImageVC(imageContainer: image)
        }
      case .demographics:
        if let displayData = sectionItem.demographics {
          self.addDemographicsVC(locationName: displayData.locationName,
                                 schoolName: displayData.school,
                                 schoolYear: displayData.schoolYear)
        }
      case .bio:
        if let bioItem = sectionItem.bio {
          self.addBioItem(bioItem: bioItem)
        }
      case .question:
        if let questionItem = sectionItem.question {
          self.addQuestionResponseItem(responseItem: questionItem)
        }
      }
    }
  }
  
  func addNameAge(name: String, age: Int?) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = self.backgroundColor
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
    spacer.backgroundColor = self.backgroundColor
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.stackView.addArrangedSubview(spacer)
  }
  
  func addLineView() {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let lineView = UIView()
    lineView.translatesAutoresizingMaskIntoConstraints = false
    lineView.backgroundColor = UIColor(white: 0.5, alpha: 0.125)
    
    containerView.addSubview(lineView)
    containerView.addConstraints([
      NSLayoutConstraint(item: lineView, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: lineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
      NSLayoutConstraint(item: lineView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
      ])
    
    self.stackView.addArrangedSubview(containerView)
    self.stackView.addConstraints([
      NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
      NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self.stackView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
      ])
  }
  
  func addSectionTitle(title: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
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
  
  func addImageVC(imageContainer: ImageContainer) {
    guard let imageVC = ProfileImageViewController.instantiate(imageContainer: imageContainer) else {
      print("Failed to create Image VC")
      return
    }
    self.addChild(imageVC)
    imageVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.addVCToCard(view: imageVC.view)
    imageVC.didMove(toParent: self)
  }
  
  func addVCToCard(view: UIView) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = self.backgroundColor
    let cardShadowView = UIView()
    let cardView = UIView()
    containerView.addSubview(cardShadowView)
    containerView.addSubview(cardView)
    cardShadowView.translatesAutoresizingMaskIntoConstraints = false
    cardShadowView.layer.cornerRadius = 12
    cardShadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    cardShadowView.layer.shadowColor = UIColor(white: 0.2, alpha: 0.05).cgColor
    cardShadowView.layer.shadowOpacity = 1.0
    cardShadowView.layer.shadowRadius = 8.0
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
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: self.cardBetweenSpacing / 2.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -self.cardBetweenSpacing / 2.0),
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: self.cardEdgeSpacing),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -self.cardEdgeSpacing)
      ])
    
    self.stackView.addArrangedSubview(containerView)
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
    self.addVCToCard(view: demographicsVC.view)
    demographicsVC.didMove(toParent: self)
  }
  
  func addBioItem(bioItem: BioItem) {
    
  }
  
  func addQuestionResponseItem(responseItem: QuestionResponseItem) {
    
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
  
  func addDoDontVC(doDontType: DoDontType, doDontContent: [DoDontContent]) {
    guard let doDontVC = ProfileDoDontViewController.instantiate(doDontType: doDontType, doDontContent: doDontContent) else {
      print("Failed to instantiate Do Dont VC")
      return
    }
    self.addChild(doDontVC)
    self.stackView.addArrangedSubview(doDontVC.view)
    doDontVC.didMove(toParent: self)
  }
  
}
