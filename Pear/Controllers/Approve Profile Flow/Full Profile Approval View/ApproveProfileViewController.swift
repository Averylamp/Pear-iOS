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
  @IBOutlet weak var titleLabel: UILabel!
  var profileData: FullProfileDisplayData!
  var detachedProfile: PearDetachedProfile!
  var isApprovingProfile = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileData: FullProfileDisplayData, detachedProfile: PearDetachedProfile) -> ApproveProfileViewController? {
    guard let approveDetachedProfileVC = R.storyboard.approveProfileViewController()
      .instantiateInitialViewController() as? ApproveProfileViewController else { return nil }
    approveDetachedProfileVC.profileData = profileData
    approveDetachedProfileVC.detachedProfile = detachedProfile
    return approveDetachedProfileVC
  }
  
  @objc func skipButtonClicked(sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func saveButtonClicked(sender: UIButton) {
    if self.isApprovingProfile {
      return
    }
    self.isApprovingProfile = true
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    if let currentUserID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.attachDetachedProfile(detachedProfile: self.detachedProfile) { (result) in
                                                    DispatchQueue.main.async {
                                                      
                                                      switch result {
                                                      case .success(let success):
                                                        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                                                        print("Successfully attached detached profile: \(success)")
                                                        if success {
                                                          DataStore.shared.refreshPearUser(completion: nil)
                                                          DataStore.shared.refreshEndorsedUsers(completion: nil)
                                                          if DataStore.shared.hasUpdatedPreferences() {
                                                            DataStore.shared.getNotificationAuthorizationStatus { status in
                                                              print("**NOTIF AUTH STATUS**")
                                                              print(status)
                                                              if status == .notDetermined {
                                                                DispatchQueue.main.async {
                                                                  guard let allowNotificationVC = ApproveProfileAllowNotificationsViewController.instantiate() else {
                                                                    print("Failed to create Allow Notifications VC")
                                                                    return
                                                                  }
                                                                  self.navigationController?.setViewControllers([allowNotificationVC], animated: true)
                                                                }
                                                              } else {
                                                                DispatchQueue.main.async {
                                                                  self.dismiss(animated: true, completion: nil)
                                                                }
                                                              }
                                                            }
                                                          } else {
                                                            guard let updateUserVC = UpdateUserPreferencesViewController.instantiate() else {
                                                              print("Failed to initialize Update User Pref VC")
                                                              return
                                                            }
                                                            self.navigationController?.setViewControllers([updateUserVC], animated: true)
                                                          }
                                                        } else {
                                                          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                                                          self.alert(title: "Failed to Accept", message: "Unfortunately there was a problem with our servers.  Try again later")
                                                        }
                                                      case .failure(let error):
                                                        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                                                        self.alert(title: "Failed to Accept", message: "Unfortunately there was a problem with our servers.  Try again later")
                                                        print("Failed to attach detached profile: \(error)")
                                                      }
                                                      self.isApprovingProfile = false
                                                    }
                                                    
      }
    }

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
    if let authorName = self.detachedProfile.creatorFirstName {
      self.titleLabel.text = "\(authorName) added to your profile"
    }
  }
  
  func setup() {
    self.addDemographcsVC(firstName: DataStore.shared.currentPearUser?.firstName,
                          age: DataStore.shared.currentPearUser?.age,
                          schoolName: DataStore.shared.currentPearUser?.school,
                          locationName: DataStore.shared.currentPearUser?.matchingDemographics.location?.locationName,
                          vibes: self.profileData.vibes)
    
    let sectionItems = FullProfileStackViewController.sectionItemsFromProfile(profile: self.profileData)
    for sectionItem in sectionItems {
      switch sectionItem.sectionType {
      case .image:
        break
      default:
        break
//      case .textItems:
//        if let textItems = sectionItem.textItems {
//          if sectionItem.textItems is [BioItem]? {
//            self.addSectionTitle(title: "BIOS", backgroundColor: R.color.backgroundColorBlue())
//          } else if sectionItem.textItems is [BoastItem]? {
//            self.addSectionTitle(title: "BOASTS", backgroundColor: R.color.backgroundColorOrange())
//          } else if sectionItem.textItems is [RoastItem]? {
//            self.addSectionTitle(title: "ROASTS", backgroundColor: R.color.backgroundColorRed())
//          }
//          self.addSpacerView(height: 8)
//          self.addScrollableTextContent(content: textItems)
//          self.addSpacerView(height: 8)
//        }
//      case .questions:
//        if let questionItems = sectionItem.question {
//          self.addSectionTitle(title: "Q&A", backgroundColor: R.color.backgroundColorYellow())
//          self.addSpacerView(height: 8)
//          self.addScrollableQuestionContent(content: questionItems)
//          self.addSpacerView(height: 8)
//        }
      }
    }
    self.addApprovalButtons()
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
  
  func addSpacerView(height: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = nil
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.stackView.addArrangedSubview(spacer)
  }
  
  func addDemographcsVC(firstName: String?,
                        age: Int?,
                        schoolName: String?,
                        locationName: String?,
                        vibes: [VibeItem]) {
    // TODO(@averylamp): Fix DemographicsVC addition
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
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
      ])
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addApprovalButtons() {
    let continueContainerView = UIView()
    continueContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let continueButton = UIButton()
    continueButton.addTarget(self, action: #selector(ApproveProfileViewController.saveButtonClicked(sender:)), for: .touchUpInside)
    continueButton.backgroundColor = R.color.backgroundColorPurple()
    continueButton.layer.cornerRadius = 25
    continueButton.setTitle("Continue", for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      continueButton.titleLabel?.font = font
    }
    continueButton.setTitleColor(UIColor.white, for: .normal)
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueButton)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueButton, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueButton, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueButton, attribute: .top, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .top, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: continueButton, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50),
      NSLayoutConstraint(item: continueButton, attribute: .bottom, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
      ])
    self.stackView.addArrangedSubview(continueContainerView)

  }
  
}
