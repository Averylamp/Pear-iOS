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
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: - Updating and Saving
extension FriendEditProfileViewController {
  
  func checkForEdits() -> Bool {
    if let photoVC = self.photoUpdateVC, photoVC.checkForChanges() {
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
  }
  
  func compateWithoutQuotes(first: String, second: String) -> Bool {
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
    self.addTitleSection(title: "Suggested Photos")
    self.addSubtitleSection(subtitle: "\(firstName!) will be able to choose from these photos.")
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
    
    self.addPhotosSection(images: images)
    self.addTitleSection(title: "Bio")
    self.addExpandingTextVC(initialText: bio,
                            type: .bio,
                            fixedHeight: nil,
                            allowDeleteButton: false,
                            maxHeight: nil)
    self.addSpacer(space: 15)
    self.addTitleSection(title: "Do's")
    dos.forEach({
      self.addExpandingTextVC(initialText: $0,
                              type: .doType,
                              fixedHeight: nil,
                              allowDeleteButton: true,
                              maxHeight: nil)
    })
    self.addSpacer(space: 15)
    self.addTitleSection(title: "Dont's")
    donts.forEach({
      self.addExpandingTextVC(initialText: $0,
                              type: .dontType,
                              fixedHeight: nil,
                              allowDeleteButton: true,
                              maxHeight: nil)
    })
    
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
  
  func addTextField(type: UpdateTextFieldType,
                    title: String,
                    initialText: String,
                    editable: Bool,
                    textContentType: UITextContentType? = nil) {
    guard let textFieldVC = UpdateTextFieldController.instantiate(type: type,
                                                                  initialText: initialText,
                                                                  textFieldTitle: title,
                                                                  allowEditing: editable,
                                                                  textContentType: textContentType) else {
      print("Failed to initialize text field")
      return
    }
    self.addChild(textFieldVC)
    self.stackView.addArrangedSubview(textFieldVC.view)
    textFieldVC.didMove(toParent: self)
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
    self.textViewVCs.append(expandingTextVC)
    self.addChild(expandingTextVC)
    self.stackView.addArrangedSubview(expandingTextVC.view)
    expandingTextVC.didMove(toParent: self)
    
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
