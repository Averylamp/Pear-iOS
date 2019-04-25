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

// MARK: - Life Cycle
extension FullProfileStackViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  enum SectionType {
    case textItems
    case image
    case questions
  }
  
  struct SectionItem {
    let sectionType: SectionType
    let textItems: [TextContentItem]?
    let image: ImageContainer?
    let question: [QuestionResponseItem]?
  }
  
  func sectionItemsFromProfile(profile: FullProfileDisplayData) -> [SectionItem] {
    var images = profile.imageContainers
    var textItems: [[TextContentItem]] = []
    if profile.bios.count > 0 {
      textItems.append(profile.bios as [TextContentItem])
    }
    if profile.boasts.count > 0 {
      textItems.append(profile.boasts as [TextContentItem])
    }
    if profile.roasts.count > 0 {
      textItems.append(profile.roasts as [TextContentItem])
    }
    var sectionItems: [SectionItem] = []
    while true {
      var addedItems = false
      if images.count > 0 {
        let image = images.removeFirst()
        sectionItems.append(SectionItem(sectionType: .image,
                                        textItems: nil,
                                        image: image,
                                        question: nil))
        addedItems = true
      }
      if textItems.count > 0 {
        let textItem = textItems.removeFirst()
        sectionItems.append(SectionItem(sectionType: .textItems,
                                        textItems: textItem,
                                        image: nil,
                                        question: nil))
        addedItems = true
      } else if !sectionItems.contains(where: { $0.sectionType == .questions}),
        profile.questionResponses.count > 0 {
        sectionItems.append(SectionItem(sectionType: .questions,
                                        textItems: nil,
                                        image: nil,
                                        question: profile.questionResponses))
        addedItems = true
      }
      if !addedItems {
        break
      }
    }
    return sectionItems
  }
  
  func stylize() {
    
    self.addDemographcsVC(firstName: self.fullProfileData.firstName,
                          age: self.fullProfileData.age,
                          schoolName: self.fullProfileData.school,
                          locationName: self.fullProfileData.locationName,
                          vibes: self.fullProfileData.vibes)
    
    let sectionItems = self.sectionItemsFromProfile(profile: self.fullProfileData)
    for sectionItem in sectionItems {
      switch sectionItem.sectionType {
      case .image:
        if let image = sectionItem.image {
          self.addImageVC(imageContainer: image)
        }
      case .textItems:
        if sectionItem.textItems is [BioItem]? {
          self.addSectionTitle(title: "BIOS")
        } else if sectionItem.textItems is [BoastItem]? {
          self.addSectionTitle(title: "BOASTS")
        } else if sectionItem.textItems is [RoastItem]? {
          self.addSectionTitle(title: "ROASTS")
        }
        if let textItems = sectionItem.textItems {
          self.addScrollableContent(content: textItems)
        }
      case .questions:
        break
      }
      
    }
    
  }
  
  func addSpacerView(height: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = nil
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
  
  func addDemographcsVC(firstName: String?,
                        age: Int?,
                        schoolName: String?,
                        locationName: String?,
                        vibes: [VibeItem]) {
    guard let demographicsVC = ProfileDemographicsViewController.instantiate(firstName: firstName,
                                                                             age: age,
                                                                             schoolName: schoolName,
                                                                             locationName: locationName,
                                                                             vibes: vibes) else {
                                                                              print("Failed to create Demographics VC")
                                                                              return
    }
    
    self.addChild(demographicsVC)
    self.stackView.addArrangedSubview(demographicsVC.view)
    demographicsVC.didMove(toParent: self)
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
    self.stackView.addArrangedSubview(imageVC.view)
    imageVC.didMove(toParent: self)
  }
  
  func addScrollableContent(content: [TextContentItem]) {
    guard let scrollableContentVC = ScrollableTextItemViewController.instantiate(items: content) else {
      print("failed to instantiate scrollable text item")
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
