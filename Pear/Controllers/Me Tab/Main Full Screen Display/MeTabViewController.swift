//
//  MeTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension Notification.Name {
  static let refreshMeTab = Notification.Name("refreshMeTab")
}

class MeTabViewController: UIViewController {
  
  var fullProfile: FullProfileDisplayData?

  @IBOutlet weak var floatingEditButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  var currentPearUser: PearUser?
  
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
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let inviteButton = UIButton()
    inviteButton.addTarget(self, action: #selector(MeTabViewController.inviteFriendsButtonClicked(sender:)), for: .touchUpInside)
    inviteButton.translatesAutoresizingMaskIntoConstraints = false
    inviteButton.setTitle("Invite Friends", for: .normal)
    containerView.addSubview(inviteButton)
    inviteButton.addConstraint(NSLayoutConstraint(item: inviteButton, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
    
    containerView.addConstraints([
      NSLayoutConstraint(item: inviteButton, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: inviteButton, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: inviteButton, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: inviteButton, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
      ])

    fullProfileStackVC.stackView.addArrangedSubview(containerView)
    
    self.view.layoutIfNeeded()
    
    inviteButton.stylizeDark()
  }
  
}
