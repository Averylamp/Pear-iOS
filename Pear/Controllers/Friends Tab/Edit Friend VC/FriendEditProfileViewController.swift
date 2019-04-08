//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendEditProfileViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var detachedProfile: PearDetachedProfile?
  var userProfile: PearUserProfile?
  var firstName: String!
  let leadingSpace: CGFloat = 12
  var isUpdating: Bool = false
  
  var photoUpdateVC: UpdateImagesViewController?
  var textViewVCs: [UpdateExpandingTextViewController] = []
  
  class func instantiate(detachedProfile: PearDetachedProfile?,
                         userProfile: PearUserProfile?,
                         firstName: String) -> FriendEditProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendEditProfileViewController.self), bundle: nil)
    guard let editFriendVC = storyboard.instantiateInitialViewController() as? FriendEditProfileViewController else { return nil }
    if detachedProfile == nil && userProfile == nil {
      print("Both friend profiles types are nil")
      return nil
    }
    editFriendVC.detachedProfile = detachedProfile
    editFriendVC.userProfile = userProfile
    editFriendVC.firstName = firstName
    return editFriendVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    if checkForEdits() {
      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .warning)
      let alertController = UIAlertController(title: "Are you sure?",
                                              message: "Your unsaved changes will be lost.",
                                              preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let goBackAction = UIAlertAction(title: "Don't Save", style: .destructive) { (_) in
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }
      }
      alertController.addAction(goBackAction)
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil)
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    self.saveChanges {
      DispatchQueue.main.async {
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        DataStore.shared.refreshEndorsedUsers(completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
  }
  
  func compareStringArrays(first: [String], second: [String]) -> Bool {
    if first.count != second.count {
      return false
    }
    for index in 0..<first.count {
      if !compareWithoutQuotes(first: first[index], second: second[index]) {
        return false
      }
    }
    return true
  }
  
  func getUpdates() -> [String: Any] {
    var updates: [String: Any] = [:]
    var bio: String = ""
    self.textViewVCs.forEach({ if $0.type == .bio { bio = $0.expandingTextView.text } })
    var dos: [String] = []
    self.textViewVCs.forEach({ if $0.type == .doType { dos.append($0.expandingTextView.text) } })
    var donts: [String] = []
    self.textViewVCs.forEach({ if $0.type == .dontType { donts.append($0.expandingTextView.text) } })
    
    if let detachedProfile = self.detachedProfile {
      if !compareWithoutQuotes(first: bio, second: detachedProfile.bio) {
        updates["bio"] = bio
      }
      if !compareStringArrays(first: dos, second: detachedProfile.dos) {
        updates["dos"] = dos
      }
      if !compareStringArrays(first: donts, second: detachedProfile.donts) {
        updates["donts"] = donts
      }
      if let photoVC = self.photoUpdateVC, photoVC.didMakeUpdates() {
        updates["images"] = photoVC.images
          .filter({ $0.imageContainer != nil })
          .map({ $0.imageContainer!.dictionary })
          .filter({$0 != nil})
      }
    } else if let userProfile = self.userProfile {
      if !compareWithoutQuotes(first: bio, second: userProfile.bio) {
        updates["bio"] = bio
      }
      if !compareStringArrays(first: dos, second: userProfile.dos) {
        updates["dos"] = dos
      }
      if !compareStringArrays(first: donts, second: userProfile.donts) {
        updates["donts"] = donts
      }
    }
    
    return updates
  }
  
  func saveChanges(completion: (() -> Void)?) {
    if isUpdating {
      return
    }
    self.isUpdating = true
    let updates = self.getUpdates()
    if updates.count == 0 {
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
    if let detachedProfile = self.detachedProfile {
      PearProfileAPI.shared.editDetachedProfile(profileDocumentID: detachedProfile.documentID,
                                                userID: userID,
                                                updates: updates) { (result) in
                                                  switch result {
                                                  case .success(let successful):
                                                    if successful {
                                                      print("Successful detached profile update")
                                                    } else {
                                                      print("Failed to update detached profile")
                                                    }
                                                  case .failure(let error):
                                                    print("Failure updating detached profile:\(error)")
                                                  }
                                                  if let completion = completion {
                                                    completion()
                                                  }
                                                  self.isUpdating = false
      }
    } else if let userProfile = self.userProfile {
      PearProfileAPI.shared.editUserProfile(profileDocumentID: userProfile.documentID,
                                            userID: userID,
                                            updates: updates) { (result) in
                                              switch result {
                                              case .success(let successful):
                                                if successful {
                                                  print("Successful user profile update")
                                                } else {
                                                  print("Failed to update user profile")
                                                }
                                              case .failure(let error):
                                                print("Failure updating user profile:\(error)")
                                              }
                                              if let completion = completion {
                                                completion()
                                              }
                                              self.isUpdating = false
      }
    }
    
  }
  
}

// MARK: - Updating and Saving
extension FriendEditProfileViewController {
  
  func checkForEdits() -> Bool {
    if let photoVC = self.photoUpdateVC, photoVC.didMakeUpdates() {
      return true
    }
    let updates = self.getUpdates()
    if updates.count > 0 {
      return true
    }
    return false
  }
  
}

// MARK: - Life Cycle
extension FriendEditProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.constructEditProfile()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
    
  }
  
  func stylize() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = "Edit \(firstName!)'s Profile"
    self.doneButton.stylizeEditAddSection()
  }
  
  func compareWithoutQuotes(first: String, second: String) -> Bool {
    return first.replacingOccurrences(of: "\"", with: "") == second.replacingOccurrences(of: "\"", with: "")
  }
  
  func removeFirstLastCharacter(text: String) -> String {
    guard text.count > 1 else {
      print("SHOULDNT EVER HAPPEN TEXT MISFORMED")
      return ""
    }
    return text[1..<text.count - 1]
  }
  
  func constructEditProfile() {
    self.addSpacer(space: 20)
    var images: [LoadedImageContainer] = []
    var bio: String = ""
    var dos: [String] = []
    var donts: [String] = []
    if let detachedProfile = self.detachedProfile {
      images.append(contentsOf: detachedProfile.images.map({ $0.loadedImageContainer() }))
      bio = removeFirstLastCharacter(text: detachedProfile.bio)
      dos.append(contentsOf: detachedProfile.dos.map({  removeFirstLastCharacter(text: $0) }))
      donts.append(contentsOf: detachedProfile.donts.map({  removeFirstLastCharacter(text: $0) }))
    } else if let userProfile = self.userProfile {
      bio = removeFirstLastCharacter(text: userProfile.bio)
      dos.append(contentsOf: userProfile.dos.map({  removeFirstLastCharacter(text: $0) }))
      donts.append(contentsOf: userProfile.donts.map({  removeFirstLastCharacter(text: $0) }))
    }
    
    // Only detached profiles have image editing ability
    if self.detachedProfile != nil {
      self.addTitleSection(title: "Suggested Photos")
      self.addSubtitleSection(subtitle: "\(firstName!) will be able to choose from these photos.")
      self.addPhotosSection(images: images)
    }
    
    self.addTitleSection(title: "Bio")
    self.addExpandingTextVC(initialText: bio,
                            type: .bio,
                            fixedHeight: nil,
                            allowDeleteButton: false,
                            maxHeight: nil)
    self.addSpacer(space: 15)
    self.addDoDontTitle(type: .doType)
    dos.forEach({
      self.addExpandingTextVC(initialText: $0,
                              type: .doType,
                              fixedHeight: nil,
                              allowDeleteButton: true,
                              maxHeight: nil)
    })
    self.addSpacer(space: 15)
    self.addDoDontTitle(type: .dontType)
    donts.forEach({
      self.addExpandingTextVC(initialText: $0,
                              type: .dontType,
                              fixedHeight: nil,
                              allowDeleteButton: true,
                              maxHeight: nil)
    })
    self.addSpacer(space: 30)
  }
  
  func addSpacer(space: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: space))
    self.stackView.addArrangedSubview(spacer)
  }
  
  func addDoDontTitle(type: DoDontType) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.stylizeEditTitleLabel()
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
    
    let addFieldButton = UIButton()
    addFieldButton.translatesAutoresizingMaskIntoConstraints = false
    addFieldButton.setTitle("Add", for: .normal)
    addFieldButton.stylizeEditAddSection()
    containerView.addSubview(addFieldButton)
    containerView.addConstraints([
      NSLayoutConstraint(item: addFieldButton, attribute: .centerY, relatedBy: .equal,
                         toItem: titleLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: addFieldButton, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0)
      ])
    
    switch type {
    case .doType:
      titleLabel.text = "Do's"
      addFieldButton.addTarget(self, action: #selector(FriendEditProfileViewController.addDoSection), for: .touchUpInside)
    case .dontType:
      titleLabel.text = "Dont's"
      addFieldButton.addTarget(self, action: #selector(FriendEditProfileViewController.addDontSection), for: .touchUpInside)
    }
    self.stackView.addArrangedSubview(containerView)
  }
  
  @objc func addDoSection() {
    self.addExpandingTextController(type: .doType)
  }
  
  @objc func addDontSection() {
    self.addExpandingTextController(type: .dontType)
  }
  
  func addExpandingTextController(type: ExpandingTextViewControllerType) {
    guard type == .dontType || type == .doType else {
      print("Not allowed to add not do/dont types")
      return
    }
    var lastOfType: UpdateExpandingTextViewController?
    self.textViewVCs.forEach({
      if $0.type == type {
        lastOfType = $0
      }
    })
    guard let lastExpandingTextVC = lastOfType,
      let insertionIndex = self.textViewVCs.firstIndex(of: lastExpandingTextVC),
      let arrangedSubviewIndex = self.stackView.arrangedSubviews.firstIndex(where: { $0 == lastExpandingTextVC.view })  else {
        print("Failed to find expanding text VC of type \(type)")
        return
    }
    
    guard let expandingTextVC = UpdateExpandingTextViewController
      .instantiate(initialText: "",
                   type: type,
                   fixedHeight: nil,
                   allowDeleteButton: true,
                   maxHeight: nil) else {
                    print("Failed to create expanding text vc")
                    return
    }
    expandingTextVC.delegate = self
    self.textViewVCs.insert(expandingTextVC, at: insertionIndex + 1)
    self.addChild(expandingTextVC)
    self.stackView.insertArrangedSubview(expandingTextVC.view, at: arrangedSubviewIndex + 1)
    expandingTextVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    expandingTextVC.expandingTextView.becomeFirstResponder()
    self.scrollView.scrollRectToVisible(expandingTextVC.view.frame, animated: true)
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
    titleLabel.text = subtitle
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
  
  func addPhotosSection(images: [LoadedImageContainer]) {
    guard let photosVC = UpdateImagesViewController.instantiate(images: images) else {
      print("failed to create photo edit VC")
      return
    }
    self.photoUpdateVC = photosVC
    
    self.addChild(photosVC)
    self.stackView.addArrangedSubview(photosVC.view)
    photosVC.didMove(toParent: self)
  }
  
  func addExpandingTextVC(initialText: String,
                          type: ExpandingTextViewControllerType,
                          fixedHeight: CGFloat?,
                          allowDeleteButton: Bool,
                          maxHeight: CGFloat?) {
    
    guard let expandingTextVC = UpdateExpandingTextViewController
      .instantiate(initialText: initialText,
                   type: type,
                   fixedHeight: fixedHeight,
                   allowDeleteButton: allowDeleteButton,
                   maxHeight: maxHeight) else {
                    print("Failed to create expanding text vc")
                    return
    }
    expandingTextVC.delegate = self
    self.textViewVCs.append(expandingTextVC)
    self.addChild(expandingTextVC)
    self.stackView.addArrangedSubview(expandingTextVC.view)
    expandingTextVC.didMove(toParent: self)
    
  }
  
}

// MARK: - Update Expanding Text View Delegate
extension FriendEditProfileViewController: UpdateExpandingTextViewDelegate {
  
  func deleteButtonPressed(controller: UpdateExpandingTextViewController) {
    guard controller.type == .doType || controller.type == .dontType else {
      print("Not allowed to remove non do/dont types")
      return
    }
    var matchingCount = 0
    self.textViewVCs.forEach({ if controller.type == $0.type { matchingCount += 1 }})
    guard matchingCount > 1 else {
      print("Cant remove last remaining item")
      controller.expandingTextView.text = ""
      return
    }
    guard self.stackView.arrangedSubviews.firstIndex(where: { $0 == controller.view }) != nil,
      let arrayIndex = self.textViewVCs.firstIndex(of: controller) else {
        print("Unable to find indices to remove")
        return
    }
    
    self.stackView.removeArrangedSubview(controller.view)
    controller.view.removeFromSuperview()
    self.textViewVCs.remove(at: arrayIndex)
  }
  
}

// MARK: - Keybaord Size Notifications
extension FriendEditProfileViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FriendEditProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FriendEditProfileViewController.keyboardWillHide(notification:)),
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
extension FriendEditProfileViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendEditProfileViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
