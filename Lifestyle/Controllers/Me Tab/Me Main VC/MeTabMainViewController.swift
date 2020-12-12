//
//  MeTabMainViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import MessageUI

extension Notification.Name {
  static let refreshMeTab = Notification.Name("refreshMeTab")
}

class MeTabMainViewController: UIViewController {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var profileImageContainerView: UIView!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var meTabItemTableView: UITableView!
  
  var meTabItems: [MeTabItem] = [
    MeTabItem(type: .myFriends),
    MeTabItem(type: .editProfile),
    MeTabItem(type: .myPreferences),
    MeTabItem(type: .accountSettings),
    MeTabItem(type: .needHelp),
    MeTabItem(type: .feedback)
  ]
  
  enum MeTabItemType {
    case myFriends
    case editProfile
    case myPreferences
    case accountSettings
    case needHelp
    case feedback
  }
  
  struct MeTabItem {
    let type: MeTabItemType
  }
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MeTabMainViewController? {
    guard let meTabMainVC = R.storyboard.meTabMainViewController
      .instantiateInitialViewController()  else { return nil }
    return meTabMainVC
  }
  
  @IBAction func imageViewClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    SlackHelper.shared.addEvent(text: "Clicked on Profile Image", color: UIColor.green)
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to get user")
      return
    }
    guard let fullProfileScrollView = FullProfileScrollViewController.instantiate(fullProfileData: FullProfileDisplayData(user: user))else {
      print("Unable to instantiate full profile scroll view")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollView, animated: true)
  }
  
}
// MARK: - Life Cycle
extension MeTabMainViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    self.meTabItemTableView.delegate = self
    self.meTabItemTableView.dataSource = self
    self.addNotifications()
  }
  
  func addNotifications() {
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(MeTabMainViewController.updateWithCurrentUser),
                   name: .refreshMeTab, object: nil)
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(MeTabMainViewController.goToEditProfileNotification(notification:)),
                   name: .goToEditProfile,
                   object: nil)
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(MeTabMainViewController.goToEditFriendsProfileNotification(notification:)),
                   name: .goToFriendsTab,
                   object: nil)
  }
  
  func stylize() {
    self.meTabItemTableView.separatorStyle = .none
    guard let user = DataStore.shared.currentPearUser else {
      print("Unable to get Current Pear User")
      return
    }
    if let firstImageString = user.displayedImages.first?.medium.imageURL,
      let imageURL = URL(string: firstImageString) {
      self.profileImageView.sd_setImage(with: imageURL, completed: nil)
    }
    self.profileNameLabel.text = user.fullName()
    self.profileImageView.contentMode = .scaleAspectFill
    self.profileImageView.layer.cornerRadius  = self.profileImageView.frame.height / 2.0
  }
  
  @objc func updateWithCurrentUser() {
    DispatchQueue.main.async {
      self.stylize()
    }
  }
  
}

// MARK: - Redirect Functions
extension MeTabMainViewController {
  
  func goToMyFriendsVC() {
    SlackHelper.shared.addEvent(text: "User clicked on `My Friends` option", color: UIColor.orange)
    guard let friendMainVC = FriendsTabViewController.instantiate() else {
      print("Unable to instantiate friends tab VC")
      return
    }
    self.navigationController?.pushViewController(friendMainVC, animated: true)
  }
  
  func goToEditProfileVC() {
    SlackHelper.shared.addEvent(text: "User clicked on `Edit Profile` option", color: UIColor.orange)
    guard let editPreviewVC = EditPreviewViewController.instantiate() else {
      print("Unable to create edit preview VC")
      return
    }
    self.navigationController?.pushViewController(editPreviewVC, animated: true)
  }
  
  func goToEditPreferencesVC() {
    SlackHelper.shared.addEvent(text: "User clicked on `Edit Preferences` option", color: UIColor.orange)
    guard let editUserPreferencesVC = MeEditUserPreferencesViewController.instantiate() else {
      print("Unable to instantiate edit user preferences")
      return
    }
    self.navigationController?.pushViewController(editUserPreferencesVC, animated: true)
  }
  
  func goToAccountSettingsVC() {
    SlackHelper.shared.addEvent(text: "User clicked on `Account Settings` option", color: UIColor.orange)
    guard let accountSettingsVC = AccountSettingsViewController.instantiate() else {
      print("Unable to instantiate Account settings preferences")
      return
    }
    self.navigationController?.pushViewController(accountSettingsVC, animated: true)
  }
  
  func goToFriendFullProfileVC(fullProfile: FullProfileDisplayData) {
    SlackHelper.shared.addEvent(text: "User redirected to `Friend Full Profile`", color: UIColor.orange)
    guard let friendMainVC = FriendsTabViewController.instantiate() else {
      print("Unable to instantiate friends tab VC")
      return
    }
    self.navigationController?.pushViewController(friendMainVC, animated: false)
    guard let friendFullProfileVC = FriendFullProfileViewController.instantiate(fullProfileData: fullProfile) else {
      print("Unbale to instantiate friend full profile VC")
      return
    }
    self.navigationController?.pushViewController(friendFullProfileVC, animated: true)
  }
  
  func dispatchEmailComposer(subject: String, messageBody: String) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.setSubject(subject)
    mailComposer.setToRecipients(["support@getpear.com"])
    mailComposer.setMessageBody(messageBody, isHTML: false)
    mailComposer.mailComposeDelegate = self
    self.present(mailComposer, animated: true, completion: nil)
  }
}

// MARK: - Notification Redirect
extension MeTabMainViewController {
  
  func popToRootIfNeeded() {
    if let controllerCount = self.navigationController?.viewControllers.count,
      controllerCount > 1 {
      self.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  @objc func goToEditProfileNotification(notification: NSNotification) {
    DispatchQueue.main.async {
      self.popToRootIfNeeded()
      self.goToEditProfileVC()
    }
  }
  
  @objc func goToEditFriendsProfileNotification(notification: NSNotification) {
    DispatchQueue.main.async {
      self.popToRootIfNeeded()
      if let notificationUserInfo =  notification.userInfo,
        let friendUserID = notificationUserInfo[NotificationUserInfoKey.friendUserID.rawValue] as? String,
        let friendPearUser = DataStore.shared.endorsedUsers.first(where: { $0.documentID == friendUserID }) {
        let fullProfileData = FullProfileDisplayData(user: friendPearUser)
        self.goToFriendFullProfileVC(fullProfile: fullProfileData)
      } else {
        self.goToMyFriendsVC()
      }
    }
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension MeTabMainViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.meTabItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.meTabItemTVC.identifier,
                                                   for: indexPath) as? MeTabItemTableViewCell else {
                                                    print("Unable to create Me Tab TVC")
                                                    return  UITableViewCell()
    }
    let item = self.meTabItems[indexPath.row]
    switch item.type {
    case .myFriends:
      cell.optionLabel.text = "My Friends"
    case .editProfile:
      cell.optionLabel.text = "Edit Profile"
    case .myPreferences:
      cell.optionLabel.text = "My Preferences"
    case .accountSettings:
      cell.optionLabel.text = "Account Settings"
    case .needHelp:
      cell.optionLabel.text = "Need Help?"
    case .feedback:
      cell.optionLabel.text = "Feedback?"
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let item = self.meTabItems[indexPath.row]
    switch item.type {
    case .myFriends:
      self.goToMyFriendsVC()
    case .editProfile:
      self.goToEditProfileVC()
    case .myPreferences:
      self.goToEditPreferencesVC()
    case .accountSettings:
      self.goToAccountSettingsVC()
    case .needHelp:
      SlackHelper.shared.addEvent(text: "User clicked on `Need Help` option", color: UIColor.orange)
      self.dispatchEmailComposer(subject: "[Help] Hey I need some help!", messageBody: """
        Hey,
        
        
        
        
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        Name: \(DataStore.shared.currentPearUser?.firstName ?? "") \(DataStore.shared.currentPearUser?.lastName ?? "")
        Phone Number: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")
        """)
    case .feedback:
      SlackHelper.shared.addEvent(text: "User clicked on `Feedback` option", color: UIColor.orange)
      self.dispatchEmailComposer(subject: "[Feedback] Hey I've got some Feedback!", messageBody: """
        
        
        
        
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        Name: \(DataStore.shared.currentPearUser?.firstName ?? "") \(DataStore.shared.currentPearUser?.lastName ?? "")
        Phone Number: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")
        """)
    }
  }
}

// MARK: - MFMailComposerDelegate
extension MeTabMainViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    DispatchQueue.main.async {
      controller.dismiss(animated: true, completion: nil)
    }
  }
  
}
