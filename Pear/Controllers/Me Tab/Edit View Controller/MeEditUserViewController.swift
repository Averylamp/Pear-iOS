//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MeEditUserViewController: UIViewController {
  
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
  
  weak var photoUpdateVC: UpdateImagesViewController?
  var textFieldVCs: [UpdateTextFieldController] = []
  weak var genderPreferencesVC: UserGenderPreferencesViewController?
  weak var agePreferenceVC: UserAgePreferencesViewController?
  
  class func instantiate(profile: FullProfileDisplayData, pearUser: PearUser) -> MeEditUserViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeEditUserViewController.self), bundle: nil)
    guard let editMeVC = storyboard.instantiateInitialViewController() as? MeEditUserViewController else { return nil }
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
extension MeEditUserViewController {
  
  func checkForEdits() -> Bool {
    if let photoVC = self.photoUpdateVC, photoVC.didMakeUpdates() {
      return true
    }
    for textFieldVC in self.textFieldVCs where textFieldVC.didMakeUpdates() {
      return true
    }
    
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
  
  func getPhotoUpdates() -> [ImageContainer] {
    var updates: [ImageContainer] = []
    if let photoVC = self.photoUpdateVC, photoVC.didMakeUpdates() {
      updates = photoVC.images
        .compactMap({ $0.imageContainer })
    }
    return updates
  }
  
  func getUserUpdates() -> [String: Any] {
    var updates: [String: Any] = [:]
    
    for fieldVC in self.textFieldVCs where fieldVC.didMakeUpdates() {
      guard let inputText = fieldVC.inputTextField.text else {
        print("Failed to get input text to update")
        continue
      }
      switch fieldVC.type {
      case .firstName:
        updates["firstName"] = inputText
      case .lastName:
        updates["lastName"] = inputText
      case .birthday:
        updates["birthdate"] = inputText
      case .gender:
        print("Gender currently can't be updated")
//        updates["gender"] = inputText
      case .location:
        updates["locationName"] = inputText
      case .schoolName:
        updates["school"] = inputText
      case .schoolYear:
        updates["schoolYear"] = inputText
      case .unknown:
        break
      }
    }
    
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
    let photoUpdates = self.getPhotoUpdates()
    var updateCalls = 0
    if userUpdates.count > 0 {
      updateCalls += 1
    }
    if photoUpdates.count > 0 {
      updateCalls += 1
    }
    if updateCalls == 0 {
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
                                      updateCalls -= 1
                                      if updateCalls == 0 {
                                        self.isUpdating = false
                                        if let completion = completion {
                                          completion()
                                        }
                                      }
      }
    }
    
    if photoUpdates.count > 0 {
      PearImageAPI.shared.updateImages(userID: userID,
                                       displayedImages: photoUpdates,
                                       additionalImages: []) { (result) in
                                        switch result {
                                        case .success(let successful):
                                          if successful {
                                            print("Updating Images successful")
                                          } else {
                                            print("Updating Images failure")
                                          }
                                          
                                        case .failure(let error):
                                          print("Updating Images failure: \(error)")
                                        }
                                        updateCalls -= 1
                                        if updateCalls == 0 {
                                          self.isUpdating = false
                                          if let completion = completion {
                                            completion()
                                          }
                                        }
      }
    }
    
  }
}

// MARK: - Life Cycle
extension MeEditUserViewController {
  
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
    self.addTitleSection(title: "Photos")
    self.addPhotosSection()
    self.addTitleSection(title: "Basic Information")
    self.addTextField(type: .firstName, title: "First Name", initialText: self.pearUser.firstName ?? "")
    self.addTextField(type: .lastName, title: "Last Name", initialText: self.pearUser.lastName ?? "")
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "MMM d, yyyy"
//    let birthdate = dateFormatter.string(from: self.pearUser.birthdate)
//    self.addTextField(type: .birthday, title: "Birthday", initialText: birthdate)
    
    self.addTextField(type: .gender,
                      title: "Gender",
                      initialText: self.pearUser.matchingDemographics.gender?.toString() ?? "")
    
    self.addTextField(type: .location,
                      title: "Location (City, State)",
                      initialText: self.pearUser.matchingDemographics.location?.locationName ?? "")
    
    self.addTextField(type: .schoolName,
                      title: "School Name",
                      initialText: self.pearUser.school ?? "")
    self.addTextField(type: .schoolYear,
                      title: "School Year",
                      initialText: self.pearUser.schoolYear ?? "")
    
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
  
  func addPhotosSection() {
    var allImages: [LoadedImageContainer] = []
    self.pearUser.displayedImages.forEach({
      allImages.append($0.loadedImageContainer())
    })
    guard let photosVC = UpdateImagesViewController.instantiate(images: allImages) else {
      print("failed to create photo edit VC")
      return
    }
    self.photoUpdateVC = photosVC
    
    self.addChild(photosVC)
    self.stackView.addArrangedSubview(photosVC.view)
    photosVC.didMove(toParent: self)
  }
  
  func addTextField(type: UpdateTextFieldType,
                    title: String,
                    initialText: String) {
    guard let textFieldVC = UpdateTextFieldController.instantiate(type: type,
                                                                  initialText: initialText,
                                                                  textFieldTitle: title) else {
      print("Failed to initialize text field")
      return
    }
    self.textFieldVCs.append(textFieldVC)
    self.addChild(textFieldVC)
    self.stackView.addArrangedSubview(textFieldVC.view)
    textFieldVC.didMove(toParent: self)
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
extension MeEditUserViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserViewController.keyboardWillHide(notification:)),
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
extension MeEditUserViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeEditUserViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
