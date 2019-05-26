//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MeEditUserPreferencesViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var profile: FullProfileDisplayData!
  var pearUser: PearUser!
  let leadingSpace: CGFloat = 12
  var isUpdating: Bool = false
  
  weak var genderPreferencesVC: UserGenderPreferencesViewController?
  weak var agePreferenceVC: UserAgePreferencesViewController?
  
  class func instantiate(profile: FullProfileDisplayData, pearUser: PearUser) -> MeEditUserPreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeEditUserPreferencesViewController.self), bundle: nil)
    guard let editMeVC = storyboard.instantiateInitialViewController() as? MeEditUserPreferencesViewController else { return nil }
    editMeVC.profile = profile
    editMeVC.pearUser = pearUser
    return editMeVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    Analytics.logEvent("ME_edit_TAP_cancel", parameters: nil)
    if checkForEdits() {
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
    self.saveChanges {
      DispatchQueue.main.async {
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        DataStore.shared.refreshPearUser(completion: nil)
        self.navigationController?.popViewController(animated: true)
        Analytics.logEvent("ME_edit_TAP_done", parameters: nil)
      }
    }

  }
  
}

// MARK: - Updating and Saving
extension MeEditUserPreferencesViewController {
  
  func checkForEdits() -> Bool {
    
    if let genderPrefVC = self.genderPreferencesVC,
      genderPrefVC.didMakeUpdates() {
      return true
    }
    
    if let agePrefVC = self.agePreferenceVC,
      agePrefVC.didMakeUpdates() {
      return true
    }
    
    return false
  }
  
  func getUserUpdates() -> [String: Any] {
    var updates: [String: Any] = [:]
    if let genderPrefVC = self.genderPreferencesVC,
      genderPrefVC.didMakeUpdates() {
      updates["seekingGender"] = genderPrefVC.genderPreferences.map({ $0.rawValue })
    }
    
    if let agePrefVC = self.agePreferenceVC,
      agePrefVC.didMakeUpdates() {
      updates["minAgeRange"] = agePrefVC.minAge
      updates["maxAgeRange"] = agePrefVC.maxAge
    }
    
    return updates
  }
  
  func saveChanges(completion: (() -> Void)?) {
    if isUpdating {
      return
    }
    self.isUpdating = true
    let userUpdates = self.getUserUpdates()
    
    if userUpdates.count == 0 {
      if let completion = completion {
        print("Skipping updates")
        completion()
      }
      return
    }
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get current user")
      if let completion = completion {
        print("Skipping updates")
        completion()
      }
      return
    }

    if userUpdates.count > 0 {
      PearUserAPI.shared.updateUser(userID: userID,
                                    updates: userUpdates) { (result) in
                                      switch result {
                                      case .success(let successful):
                                        if successful {
                                          print("Updating user successful")
                                        } else {
                                          print("Updating user failure")
                                        }
                                        
                                      case .failure(let error):
                                        print("Updating user failure: \(error)")
                                      }
                                      self.isUpdating = false
                                      if let completion = completion {
                                        completion()
                                      }
                                      
      }
    }
    
  }
}

// MARK: - Life Cycle
extension MeEditUserPreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.constructEditProfile()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()

  }
  
  func stylize() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.doneButton.stylizeEditAddSection()
  }
  
  func constructEditProfile() {
    self.addSpacer(space: 20)
    self.addTitleSection(title: "Matching Preferences")
    self.addUserPreferences()
    self.addSpacer(space: 30)
  }
  
  func addSpacer(space: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: space))
    self.stackView.addArrangedSubview(spacer)
  }
  
  func addTitleSection(title: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.stylizeEditTitleLabel()
    titleLabel.text = title
    containerView.addSubview(titleLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: leadingSpace),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -leadingSpace),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4),
      NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4)
      ])
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addSubtitleSection(subtitle: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.stylizeEditSubtitleLabel()
    titleLabel.text = title
    containerView.addSubview(titleLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: leadingSpace),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -leadingSpace),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4),
      NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4)
      ])
    self.stackView.addArrangedSubview(containerView)
  }

  func addUserPreferences() {
    guard let currentUser = DataStore.shared.currentPearUser else {
      print("Failed to fetch user")
      return
    }
    
    var genderPreferences = currentUser.matchingPreferences.seekingGender
    if genderPreferences.count == 0,
      let currentGender = currentUser.gender {
      if currentGender == .male {
        genderPreferences.append(.female)
      } else if currentGender == .female {
        genderPreferences.append(.male)
      } else if currentGender == .nonbinary {
        genderPreferences = [.male, .female, .nonbinary]
      }
    }
    
    guard let userGenderPreferencesVC = UserGenderPreferencesViewController.instantiate(genderPreferences: genderPreferences) else {
      print("Unable to instantiate user gender preferences vc")
      return
    }
    stackView.addArrangedSubview(userGenderPreferencesVC.view)
    self.addChild(userGenderPreferencesVC)
    self.genderPreferencesVC = userGenderPreferencesVC
    userGenderPreferencesVC.didMove(toParent: self)
    
    guard let agePreferencesVC = UserAgePreferencesViewController
      .instantiate(minAge: currentUser.matchingPreferences.minAgeRange,
                   maxAge: currentUser.matchingPreferences.maxAgeRange) else {
                    print("Unable to instantiate user gender preferences vc")
                    return
    }
    stackView.addArrangedSubview(agePreferencesVC.view)
    self.addChild(agePreferencesVC)
    self.agePreferenceVC = agePreferencesVC
    agePreferencesVC.didMove(toParent: self)
    
  }
  
}

// MARK: - Keybaord Size Notifications
extension MeEditUserPreferencesViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserPreferencesViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserPreferencesViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetHeight = targetFrameNSValue.cgRectValue.size.height
      self.scrollViewBottomConstraint.constant = targetHeight - self.view.safeAreaInsets.bottom
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      let keyboardBottomPadding: CGFloat = 20
      self.scrollViewBottomConstraint.constant = keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
}

// MARK: - Dismiss First Responder on Click
extension MeEditUserPreferencesViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeEditUserPreferencesViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
