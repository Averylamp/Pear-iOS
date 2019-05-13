//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendEditProfileViewController: UIViewController {
  
  struct BoastRoastUpdateItem {
    let controller: ExpandingBoastRoastInputViewController
    let item: BoastRoastItem
  }
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var updateProfileData: UpdateProfileData!
  var firstName: String!
  let leadingSpace: CGFloat = 12
  var isUpdating: Bool = false
  
  var photoUpdateVC: UpdateImagesViewController?
  var textViewVCs: [UpdateExpandingTextViewController] = []
  var boastRoastVCs: [BoastRoastUpdateItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(updateProfileData: UpdateProfileData,
                         firstName: String) -> FriendEditProfileViewController? {
    guard let editFriendVC = R.storyboard.friendEditProfileViewController()
      .instantiateInitialViewController() as? FriendEditProfileViewController else { return nil }
    editFriendVC.updateProfileData = updateProfileData
    editFriendVC.firstName = firstName
    return editFriendVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    self.updateData()
    if self.updateProfileData.checkForChanges() {
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
    self.updateData()
    self.updateProfileData.saveChanges { (success) in
      if success {
        DispatchQueue.main.async {
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
          DataStore.shared.refreshEndorsedUsers(completion: nil)
          self.navigationController?.popToRootViewController(animated: true)
        }
      } else {
        print("Error saving data")
        DispatchQueue.main.async {
          self.alert(title: "Failure saving data", message: "This issue has been reported and we are working to fix it :)")
        }
      }
    }
    
  }
  
}

// MARK: - Updating and Saving
extension FriendEditProfileViewController {
  
  func updateData() {
    guard let creatorID = DataStore.shared.currentPearUser?.documentID,
      let creatorFirstName =  DataStore.shared.currentPearUser?.firstName else {
        print("Unable to find creator ID or first name")
        return
    }
    if let bioTextVC = self.textViewVCs.filter({ $0.type == .bio }).first,
      let bioText = bioTextVC.expandingTextView.text {
      if bioText.count > 0 {
        if let existingBioItem = self.updateProfileData.updatedBio {
          existingBioItem.content = bioText
        } else if let existingInitialBioItem = self.updateProfileData.initialBio?.copy() as? BioItem {
          existingInitialBioItem.content = bioText
          self.updateProfileData.updatedBio = existingInitialBioItem
        } else {
          let bioItem = BioItem(content: bioText)
          bioItem.updateAuthor(authorID: creatorID, authorFirstName: creatorFirstName)
          self.updateProfileData.updatedBio = bioItem
        }
      } else {
        self.updateProfileData.updatedBio = nil
      }
    }
    self.boastRoastVCs.forEach({ $0.item.content = $0.controller.expandingTextView.text})
    self.updateProfileData.updatedRoasts = self.boastRoastVCs.filter({ $0.controller.type == .roast && $0.controller.getBoastRoastItem() != nil })
      .compactMap({ $0.item as? RoastItem })
    self.updateProfileData.updatedBoasts = self.boastRoastVCs.filter({ $0.controller.type == .boast && $0.controller.getBoastRoastItem() != nil })
      .compactMap({ $0.item as? BoastItem })
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
  
  func constructEditProfile() {
    self.addSpacer(space: 20)
    let bio: String = self.updateProfileData.updatedBio?.content ?? ""
    let boasts: [BoastItem] = self.updateProfileData.updatedBoasts
    let roasts: [RoastItem] = self.updateProfileData.updatedRoasts
    self.addTitleSection(title: "Bio")
    self.addBioSection(bio: bio)
    
    self.addSpacer(space: 15)
//    self.addBoastRoastTitle(type: .boast)
//    boasts.forEach({
//      self.addBoastRoastSection(type: .boast, initialItem: $0)
//    })
//    if boasts.count == 0 {
//      self.addBoastRoastSection(type: .boast)
//    }
//    self.addSpacer(space: 15)
//    self.addBoastRoastTitle(type: .roast)
//    roasts.forEach({
//      self.addBoastRoastSection(type: .roast, initialItem: $0)
//    })
//    if roasts.count == 0 {
//      self.addBoastRoastSection(type: .roast)
//    }
//    self.addSpacer(space: 30)
  }
  
  func addSpacer(space: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: space))
    self.stackView.addArrangedSubview(spacer)
  }
  
  enum BoastRoastType {
    case boast
    case roast
  }
  
  func addBoastRoastTitle(type: BoastRoastType) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansExtraBold(size: 17) {
      titleLabel.font = font
    }
    titleLabel.textColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00)
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
    addFieldButton.setTitle("Add another", for: .normal)
    addFieldButton.stylizeEditAddSection()
    containerView.addSubview(addFieldButton)
    containerView.addConstraints([
      NSLayoutConstraint(item: addFieldButton, attribute: .centerY, relatedBy: .equal,
                         toItem: titleLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: addFieldButton, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0)
      ])
    
    switch type {
    case .boast:
      titleLabel.text = "Boasts"
      addFieldButton.addTarget(self, action: #selector(FriendEditProfileViewController.addBoastSection), for: .touchUpInside)
    case .roast:
      titleLabel.text = "Roasts"
      addFieldButton.addTarget(self, action: #selector(FriendEditProfileViewController.addRoastSection), for: .touchUpInside)
    }
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addBoastRoastSection(type: ExpandingBoastRoastInputType, initialItem: BoastRoastItem? = nil, focusField: Bool = false) {
    
    guard let expandingTextVC = ExpandingBoastRoastInputViewController
      .instantiate(type: type, initialText: initialItem?.content) else {
        print("Failed to create expanding b/roast text vc")
        return
    }
    expandingTextVC.delegate = self
    if let initialItem = initialItem {
      let item = BoastRoastUpdateItem(controller: expandingTextVC, item: initialItem)
      self.boastRoastVCs.append(item)
    } else {
      guard let creatorID = DataStore.shared.currentPearUser?.documentID,
        let creatorFirstName =  DataStore.shared.currentPearUser?.firstName else {
          print("Unable to find creator ID or first name")
          return
      }
      if type == .boast {
        let newItem = BoastItem(content: "")
        newItem.updateAuthor(authorID: creatorID, authorFirstName: creatorFirstName)
        let item = BoastRoastUpdateItem(controller: expandingTextVC, item: newItem)
        self.boastRoastVCs.append(item)
      } else if type == .roast {
        let newItem = RoastItem(content: "")
        newItem.updateAuthor(authorID: creatorID, authorFirstName: creatorFirstName)
        let item = BoastRoastUpdateItem(controller: expandingTextVC, item: newItem)
        self.boastRoastVCs.append(item)
      }
    }
    self.addChild(expandingTextVC)
    let lastIndex = self.stackView.arrangedSubviews.lastIndex { (existingView) -> Bool in
      return self.boastRoastVCs.contains(where: { $0.controller.view == existingView && $0.controller.type == type})
    }
    if let index = lastIndex {
      self.stackView.insertArrangedSubview(expandingTextVC.view, at: index + 1)
    } else {
      self.stackView.addArrangedSubview(expandingTextVC.view)
    }
    expandingTextVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    expandingTextVC.expandingTextContainerView.layer.borderWidth = 1
    expandingTextVC.expandingTextContainerView.layer.borderColor = UIColor(white: 0.0, alpha: 0.05).cgColor
    if focusField {
      expandingTextVC.expandingTextView.becomeFirstResponder()
    }
  }
  
  @objc func addBoastSection() {
    self.addBoastRoastSection(type: .boast, initialItem: nil, focusField: true)
  }
  
  @objc func addRoastSection() {
    self.addBoastRoastSection(type: .roast, initialItem: nil, focusField: true)
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
      .instantiate(initialText: "") else {
        print("Failed to create expanding text vc")
        return
    }
    expandingTextVC.minTextViewSize = 100
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
    if let font = R.font.openSansExtraBold(size: 17) {
      titleLabel.font = font
    }
    titleLabel.textColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00)
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
  
  func addBioSection(bio: String) {
    guard let expandingTextVC = UpdateExpandingTextViewController
      .instantiate(initialText: bio) else {
        print("Failed to create expanding text vc")
        return
    }
    expandingTextVC.type = .bio
    expandingTextVC.minTextViewSize = 100
    expandingTextVC.delegate = self
    self.textViewVCs.append(expandingTextVC)
    self.addChild(expandingTextVC)
    self.stackView.addArrangedSubview(expandingTextVC.view)
    expandingTextVC.didMove(toParent: self)
    expandingTextVC.configure()
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

// MARK: - ExpandingBoastRoastInputViewDelegate
extension FriendEditProfileViewController: ExpandingBoastRoastInputViewDelegate {
  
  func returnPressed(controller: ExpandingBoastRoastInputViewController) {
    DispatchQueue.main.async {
      self.addBoastRoastSection(type: controller.type, initialItem: nil, focusField: true)
    }
  }
  
  func deleteButtonPressed(controller: ExpandingBoastRoastInputViewController) {
    guard self.boastRoastVCs.filter({ $0.controller.type == controller.type }).count > 1 else {
      print("Cant remove last remaining item")
      controller.expandingTextView.text = ""
      return
    }
    guard self.stackView.arrangedSubviews.firstIndex(where: { $0 == controller.view }) != nil,
      let arrayIndex = self.boastRoastVCs.firstIndex(where: { $0.controller.view == controller.view}) else {
        print("Unable to find indices to remove")
        return
    }
    self.stackView.removeArrangedSubview(controller.view)
    controller.view.removeFromSuperview()
    self.boastRoastVCs.remove(at: arrayIndex)
  }
  
}
