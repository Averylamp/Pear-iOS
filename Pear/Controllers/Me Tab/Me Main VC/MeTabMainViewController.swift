//
//  MeTabMainViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import MessageUI

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
    guard let meTabMainVC = R.storyboard.meTabMainViewController()
      .instantiateInitialViewController() as? MeTabMainViewController else { return nil }
    return meTabMainVC
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
      guard let friendMainVC = FriendsTabViewController.instantiate() else {
        print("Unable to instantiate friends tab VC")
        return
      }
      self.navigationController?.pushViewController(friendMainVC, animated: true)
    case .editProfile:
      guard let user = DataStore.shared.currentPearUser else {
        print("Unable to get pear user")
        return
      }
      let fullProfileDisplay = FullProfileDisplayData(user: user)
      guard let editMeVC = MeEditUserInfoViewController.instantiate(profile: fullProfileDisplay, pearUser: user) else {
        print("Unable to instantiate edit user info VC")
        return
      }
      self.navigationController?.pushViewController(editMeVC, animated: true)
    case .myPreferences:
      guard let user = DataStore.shared.currentPearUser else {
        print("Unable to get pear user")
        return
      }
      let fullProfileDisplay = FullProfileDisplayData(user: user)
      guard let editUserPreferencesVC = MeEditUserPreferencesViewController.instantiate() else {
        print("Unable to instantiate edit user preferences")
        return
      }
      self.navigationController?.pushViewController(editUserPreferencesVC, animated: true)
    case .accountSettings:
      guard let accountSettingsVC = AccountSettingsViewController.instantiate() else {
        print("Unable to instantiate Account settings preferences")
        return
      }
      self.navigationController?.pushViewController(accountSettingsVC, animated: true)
    case .needHelp:
      let mailComposer = MFMailComposeViewController()
      mailComposer.setSubject("[Help] Hey I need some help!")
      mailComposer.setToRecipients(["support@getpear.com"])
      let messageBody = """
      Hey,
      
      
      
      
      App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
      Name: \(DataStore.shared.currentPearUser?.firstName ?? "") \(DataStore.shared.currentPearUser?.lastName ?? "")
      Phone Number: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")
      """
      mailComposer.setMessageBody(messageBody, isHTML: false)
      mailComposer.mailComposeDelegate = self
      self.present(mailComposer, animated: true, completion: nil)
    case .feedback:
      let mailComposer = MFMailComposeViewController()
      mailComposer.setSubject("[Feedback] Hey I've got some Feedback'!")
      mailComposer.setToRecipients(["support@getpear.com"])
      let messageBody = """
      
      
      
      
      App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
      Name: \(DataStore.shared.currentPearUser?.firstName ?? "") \(DataStore.shared.currentPearUser?.lastName ?? "")
      Phone Number: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")
      """
      mailComposer.setMessageBody(messageBody, isHTML: false)
      mailComposer.mailComposeDelegate = self
      self.present(mailComposer, animated: true, completion: nil)
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
