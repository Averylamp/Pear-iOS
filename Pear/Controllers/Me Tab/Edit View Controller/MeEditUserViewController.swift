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
  var pearUser: PearUser!
  let leadingSpace: CGFloat = 12
  
  var photoUpdateVC: UpdateImagesViewController?
  var textFieldVCs: [UpdateTextFieldController] = []
  
  class func instantiate(profile: FullProfileDisplayData, pearUser: PearUser) -> MeEditUserViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeEditUserViewController.self), bundle: nil)
    guard let editMeVC = storyboard.instantiateInitialViewController() as? MeEditUserViewController else { return nil }
    editMeVC.profile = profile
    editMeVC.pearUser = pearUser
    return editMeVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: - Updating and Saving
extension MeEditUserViewController {
  
  func getValueForFieldType(type: UpdateTextFieldType) -> String {
    switch type {
    case .firstName:
      return self.pearUser.firstName
    case .lastName:
      return self.pearUser.lastName
    case .birthday:
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM d, yyyy"
      return dateFormatter.string(from: self.pearUser.birthdate)
    case .gender:
       return self.pearUser.matchingDemographics.gender.toString()
    case .location:
      return self.pearUser.matchingDemographics.location.locationName ?? ""
    case .unknown:
      return ""
    }
  }
  
  func checkForEdits() -> Bool {
    if let photoVC = self.photoUpdateVC, photoVC.checkForChanges() {
      return true
    }
    var textFieldChanged = false
    self.textFieldVCs.forEach { (fieldVC) in
      if let inputText = fieldVC.inputTextField.text,
        self.getValueForFieldType(type: fieldVC.type) != inputText {
        textFieldChanged = true
      }
    }
    if textFieldChanged {
      return true
    }
    
    return false
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
  }
  
  func constructEditProfile() {
    self.addSpacer(space: 20)
    self.addPhotosSection()
    self.addTitleSection(title: "Basic Information")
    self.addTextField(type: .firstName, title: "First Name", initialText: self.pearUser.firstName, editable: false)
    self.addTextField(type: .lastName, title: "Last Name", initialText: self.pearUser.lastName, editable: false)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy"
    let birthdate = dateFormatter.string(from: self.pearUser.birthdate)
    self.addTextField(type: .birthday, title: "Birthday", initialText: birthdate, editable: false)
    
    self.addTextField(type: .gender,
                      title: "Gender",
                      initialText: self.pearUser.matchingDemographics.gender.toString(),
                      editable: false)
    
    self.addTextField(type: .location,
                      title: "Location",
                      initialText: self.pearUser.matchingDemographics.location.locationName ?? "",
                      editable: true,
                      textContentType: .addressCityAndState)
    
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
    self.textFieldVCs.append(textFieldVC)
    self.addChild(textFieldVC)
    self.stackView.addArrangedSubview(textFieldVC.view)
    textFieldVC.didMove(toParent: self)
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
