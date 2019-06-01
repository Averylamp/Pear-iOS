//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MeEditUserInfoViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var profile: FullProfileDisplayData!
  var pearUser: PearUser!
  let leadingSpace: CGFloat = 12
  var isUpdating: Bool = false
  
  weak var editUserStackVC: MeEditUserInfoStackViewController?
  
  class func instantiate(profile: FullProfileDisplayData, pearUser: PearUser) -> MeEditUserInfoViewController? {
    guard let editUserInfoVC = R.storyboard.meEditUserInfoViewController
      .instantiateInitialViewController() else { return nil }
    editUserInfoVC.profile = profile
    editUserInfoVC.pearUser = pearUser
    return editUserInfoVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    Analytics.logEvent("ME_edit_TAP_cancel", parameters: nil)
    
    if let editsMade = self.editUserStackVC?.checkForEdits(), editsMade {
      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .warning)
      let alertController = UIAlertController(title: "Are you sure?",
                                              message: "Your unsaved changes will be lost.",
                                              preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let goBackAction = UIAlertAction(title: "Don't Save", style: .destructive) { (_) in
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
          Analytics.logEvent("ME_edit_EV_discardEdits", parameters: nil)
        }
      }
      alertController.addAction(goBackAction)
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil)
    } else {
      self.navigationController?.popViewController(animated: true)
      Analytics.logEvent("ME_edit_EV_viewWithNoEdits", parameters: nil)
    }
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    self.view.endEditing(true)
    self.editUserStackVC?.saveChanges {
      DispatchQueue.main.async {
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        DataStore.shared.refreshPearUser(completion: nil)
        self.navigationController?.popViewController(animated: true)
        Analytics.logEvent("ME_edit_TAP_done", parameters: nil)
      }
    }

  }
  
}

// MARK: - Life Cycle
extension MeEditUserInfoViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.addKeyboardNotifications(animated: true)
    self.addDismissKeyboardOnViewClick()

  }
  
  func stylize() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.doneButton.stylizeEditAddSection()
  }
  
  func setup() {
    guard let editUserInfoStackVC = MeEditUserInfoStackViewController.instantiate(profile: self.profile, pearUser: self.pearUser) else {
      print("Unable to create edit user info Stack VC")
      return
    }
    self.editUserStackVC = editUserInfoStackVC
    self.addChild(editUserInfoStackVC)
    editUserInfoStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.scrollView.addSubview(editUserInfoStackVC.view)
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: editUserInfoStackVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserInfoStackVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserInfoStackVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserInfoStackVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: editUserInfoStackVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    editUserInfoStackVC.didMove(toParent: self)
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension MeEditUserInfoViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.scrollViewBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 0.0
  }
}

// MARK: - Dismiss First Responder on Click
extension MeEditUserInfoViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeEditUserInfoViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
