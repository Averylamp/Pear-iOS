//
//  AccountSettingsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import MessageUI

class AccountSettingsViewController: UIViewController {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  var isDeleting: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> AccountSettingsViewController? {
    guard let accountSettingsVC = R.storyboard.accountSettingsViewController()
      .instantiateInitialViewController() as? AccountSettingsViewController else { return nil }
    return accountSettingsVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension AccountSettingsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    
  }
  
  func stylize() {
   self.titleLabel.stylizeGeneralHeaderTitleLabel()
    self.stackView.addSpacer(height: 30)
    let inviteButtonView = self.getFeedbackButton()
    self.stackView.addArrangedSubview(inviteButtonView)
    
    let logOutButtonView = self.logoutButton()
    self.stackView.addArrangedSubview(logOutButtonView)
    
    let deleteProfileButtonView = self.deleteProfileButton()
    self.stackView.addArrangedSubview(deleteProfileButtonView)

  }
  
}

// MARK: - Button Handling
extension AccountSettingsViewController {
  @objc func logoutButtonClicked() {
    Analytics.logEvent("logout", parameters: nil)
    let defaultsName = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    do {
      try Auth.auth().signOut()
    } catch {
      print("Failed Firebase Auth")
    }
    DispatchQueue.main.async {
      guard let loadingScreen = LoadingScreenViewController.instantiate() else {
        print("Failed to instantiate loadings screen")
        return
      }
      self.navigationController?.setViewControllers([loadingScreen], animated: true)
    }
  }
  
  @objc func deleleProfileButtonClicked() {
    guard !self.isDeleting else {
      return
    }
    self.isDeleting = true
    DispatchQueue.main.async {
      let alertController =
        UIAlertController(title: "Are you sure?",
                          message: "Sorry to see you go.  We currently don't have a streamlined deletion experience, but will handle your request manually within 48 hours",
                          preferredStyle: .alert)
      
      let cancelAlert = UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
        self.isDeleting = false
      })
      let deleteAlert = UIAlertAction(title: "Continue with Deletion", style: .destructive) { (_) in
        Analytics.logEvent("delete_profile", parameters: [
          "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown"
          ])
        DispatchQueue.main.async {
          let mailComposer = MFMailComposeViewController()
          mailComposer.setSubject("[DELETE] Delete my profile please!")
          mailComposer.setToRecipients(["support@getpear.com"])
          let messageBody = """
          Name: \(DataStore.shared.currentPearUser?.firstName ?? "") \(DataStore.shared.currentPearUser?.lastName ?? "")
          Phone Number: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")
          
          If possible, we'd also love to know why you want to delete your profile and any feedback you may have for us.
          Feel free to fill out the following
          Reason:
          
          Feedback:
          
          """
          mailComposer.setMessageBody(messageBody, isHTML: false)
          mailComposer.mailComposeDelegate = self
          self.present(mailComposer, animated: true, completion: nil)
        }
      }
      alertController.addAction(cancelAlert)
      alertController.addAction(deleteAlert)
      self.present(alertController, animated: true, completion: nil)
    }
  }
 
  @objc func inviteFriendsButtonClicked(sender: UIButton) {
    guard let requestProfileVC = RequestProfileViewController.instantiate() else {
      print("Failed to create get started friend profile vc")
      return
    }
    self.present(requestProfileVC, animated: true, completion: nil)
  }
  
  @objc func sendFeedbackClicked(sender: UIButton) {
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

// MARK: - Button Generation/Layout
extension AccountSettingsViewController {
  
  func deleteProfileButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Delete Profile", for: .normal)
    button.addTarget(self, action: #selector(AccountSettingsViewController.deleleProfileButtonClicked), for: .touchUpInside)
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    button.setTitleColor(UIColor(red: 0.88, green: 0.38, blue: 0.25, alpha: 1.00), for: .normal)
    return containerView
  }
  
  func logoutButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Log Out", for: .normal)
    button.addTarget(self, action: #selector(AccountSettingsViewController.logoutButtonClicked), for: .touchUpInside)
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    button.setTitleColor(R.color.primaryTextColor(), for: .normal)
    return containerView
  }
  
  func getFeedbackButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Send Feedback", for: .normal)
    button.addTarget(self, action: #selector(AccountSettingsViewController.sendFeedbackClicked(sender:)), for: .touchUpInside)
    containerView.layoutIfNeeded()
    button.backgroundColor = R.color.primaryBrandColor()
    button.setTitleColor(UIColor.white, for: .normal)
    return containerView
  }
  
  func getButton() -> (container: UIView, button: UIButton) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(button)
    button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
    button.layer.cornerRadius = 12
    if let font = R.font.openSansBold(size: 18) {
      button.titleLabel?.font = font
    }
    
    containerView.addConstraints([
      NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
      ])
    return (container: containerView, button: button)
  }
  
}

// MARK: - MFMailComposerDelegate
extension AccountSettingsViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if !isDeleting {
      DispatchQueue.main.async {
        controller.dismiss(animated: true, completion: nil)
      }
    }
    switch result {
    case .sent:
      DispatchQueue.main.async {
        controller.dismiss(animated: true, completion: nil)
      }
      SentryHelper
        .generateSentryMessageEvent(level: .fatal,
                                    message: "Delete User: \(DataStore.shared.currentPearUser?.documentID ?? ""), Phone: \(DataStore.shared.currentPearUser?.phoneNumber ?? "")")
      self.logoutButtonClicked()
    default :
      DispatchQueue.main.async {
        controller.dismiss(animated: true, completion: nil)
      }
    }
    self.isDeleting = false
  }
  
}
