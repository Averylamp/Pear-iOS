//
//  MeTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

extension Notification.Name {
  static let refreshMeTab = Notification.Name("refreshMeTab")
}

class MeTabViewController: UIViewController {
  
  var fullProfile: FullProfileDisplayData?
  
  @IBOutlet weak var floatingEditButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  var currentPearUser: PearUser?
  var isDeleting: Bool = false
  class func instantiate() -> MeTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? MeTabViewController else { return nil }
    return matchesVC
  }
  
  @IBAction func editButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let profile = self.fullProfile,
      let pearUser = self.currentPearUser,
      let editMeVC = MeEditUserViewController.instantiate(profile: profile, pearUser: pearUser) else {
        print("Failed to instantiate edit user profile")
        return
    }
    self.navigationController?.pushViewController(editMeVC, animated: true)
  }
  
  @objc func inviteFriendsButtonClicked(sender: UIButton) {
    guard let requestProfileVC = RequestProfileViewController.instantiate() else {
      print("Failed to create get started friend profile vc")
      return
    }
    self.present(requestProfileVC, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension MeTabViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    
    self.updateWithCurrentUser()
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeTabViewController.updateWithCurrentUser),
                   name: .refreshMeTab, object: nil)
  }
  
  @objc func updateWithCurrentUser() {
    print("Reloaded Me Tab")
    self.checkForUpdatedUser()
    guard let pearUser = self.currentPearUser,
      let profile = self.fullProfile else {
        print("Failed to get pear user and profile")
        return
    }
    DispatchQueue.main.async {    
      self.refreshFullStackVC(pearUser: pearUser, profile: profile)
    }
  }
  
  func reloadPearUser() {
    DataStore.shared.refreshPearUser { (pearUser) in
      DispatchQueue.main.async {
        self.checkForUpdatedUser()
        guard let pearUser = self.currentPearUser,
          let profile = self.fullProfile else {
            print("Failed to get pear user and profile")
            return
        }
        self.refreshFullStackVC(pearUser: pearUser, profile: profile)
      }
    }
  }
  
  func checkForUpdatedUser() {
    if let user = DataStore.shared.currentPearUser {
      self.fullProfile = FullProfileDisplayData(user: user)
      self.currentPearUser = user
    }
  }
  
  func stylize() {
    self.floatingEditButton.layer.cornerRadius = 30
    self.floatingEditButton.layer.shadowOpacity = 0.2
    self.floatingEditButton.layer.shadowColor = UIColor.black.cgColor
    self.floatingEditButton.layer.shadowRadius = 6
    self.floatingEditButton.layer.shadowOffset = CGSize(width: 2, height: 2)
  }
  
  func refreshFullStackVC(pearUser: PearUser, profile: FullProfileDisplayData) {
    self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
    
    guard let fullProfile = self.fullProfile else {
      print("Failed to get full profile")
      return
    }
    
    if pearUser.endorserIDs.count == 0,
      let incompleteImage = R.image.meIncompleteProfile() {
      //      fullProfile.rawImages.append(incompleteImage)
    }
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: fullProfile) else {
      print("Failed to create full profiles stack VC")
      return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)
    
    let inviteButtonView = self.getInviteButton()
    fullProfileStackVC.stackView.addArrangedSubview(inviteButtonView)
    
    let logOutButtonView = self.logoutButton()
    fullProfileStackVC.stackView.addArrangedSubview(logOutButtonView)
    
    let deleteProfileButtonView = self.deleteProfileButton()
    fullProfileStackVC.stackView.addArrangedSubview(deleteProfileButtonView)
    
    self.view.layoutIfNeeded()
  }
  
  @objc func logoutButtonClicked() {
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
  
  func deleteProfileButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Delete Profile", for: .normal)
    button.addTarget(self, action: #selector(MeTabViewController.deleleProfileButtonClicked), for: .touchUpInside)
    button.backgroundColor = R.color.backgroundColorRed()
    button.addButtonShadow()
    return containerView
  }
  
  func logoutButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Log Out", for: .normal)
    button.addTarget(self, action: #selector(MeTabViewController.logoutButtonClicked), for: .touchUpInside)
    button.backgroundColor = R.color.backgroundColorOrange()
    button.addButtonShadow()
    return containerView
  }
  
  func getInviteButton() -> UIView {
    let (containerView, button) = self.getButton()
    button.setTitle("Invite Friends", for: .normal)
    button.addTarget(self, action: #selector(MeTabViewController.inviteFriendsButtonClicked(sender:)), for: .touchUpInside)
    containerView.layoutIfNeeded()
    button.stylizeDark()
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
    button.layer.cornerRadius = 25
    
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
extension MeTabViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
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
