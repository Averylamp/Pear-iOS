//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MeEditUserViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var profile: FullProfileDisplayData!
  let leadingSpace: CGFloat = 12
  
  var photoUpdateVC: UpdateImagesViewController?
  
  class func instantiate(profile: FullProfileDisplayData) -> MeEditUserViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeEditUserViewController.self), bundle: nil)
    guard let editMeVC = storyboard.instantiateInitialViewController() as? MeEditUserViewController else { return nil }
    editMeVC.profile = profile
    return editMeVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    
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
    self.profileNameLabel.text = self.profile.firstName
    
  }
  
  func constructEditProfile() {
    self.addSpacer(space: 20)
    self.addPhotosSection()
    self.addSingleField(title: "Bio", initialText: "Here is the bio of my friend")
    self.addSingleField(title: "Bio", initialText: "Here is the bio of my friend")
    self.addSingleField(title: "Bio", initialText: "Here is the bio of my friend")
    
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
    self.addTitleSection(title: "Photos")
    var allImages: [LoadedImageContainer] = []
    self.profile.imageContainers.forEach({
      allImages.append($0.loadedImageContainer())
    })
    self.profile.rawImages.forEach({
      allImages.append($0.gettingStartedImage())
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
  
  func addSingleField(title: String, initialText: String = "") {
    self.addTitleSection(title: title)
    guard let expandingTextVC = UpdateExpandingTextViewController
      .instantiate(initialText: initialText,
                   type: .bio,
                   fixedHeight: nil,
                   allowDeleteButton: true,
                   maxHeight: nil) else {
                    print("Failed to create expanding text vc")
                    return
    }
    self.addChild(expandingTextVC)
    self.stackView.addArrangedSubview(expandingTextVC.view)
    expandingTextVC.didMove(toParent: self)
    
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
