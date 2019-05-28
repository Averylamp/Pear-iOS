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
  
  class func instantiate(profile: FullProfileDisplayData, pearUser: PearUser) -> MeEditUserInfoViewController? {
    guard let editUserInfoVC = R.storyboard.meEditUserInfoViewController
      .instantiateInitialViewController() else { return nil }
    editUserInfoVC.profile = profile
    editUserInfoVC.pearUser = pearUser
    return editUserInfoVC
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
extension MeEditUserInfoViewController {
  
  func checkForEdits() -> Bool {
    if let photoVC = self.photoUpdateVC, photoVC.didMakeUpdates() {
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
  
  func saveChanges(completion: (() -> Void)?) {
    if isUpdating {
      return
    }
    if let images = self.photoUpdateVC?.images, images.count != images.compactMap({ $0.imageContainer }).count {
      self.delay(delay: 0.5) {
        self.saveChanges(completion: completion)
        return
      }
      return
    }
    self.isUpdating = true
    let photoUpdates = self.getPhotoUpdates()
    if photoUpdates.count == 0 {
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
                                        self.isUpdating = false
                                        if let completion = completion {
                                          completion()
                                        }
      }
    }
    
  }
}

// MARK: - Life Cycle
extension MeEditUserInfoViewController {
  
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
    self.addSpacer(space: 30)
    self.addBasicInfo()
    self.addSpacer(space: 20)
    self.addMoreInfo()
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
  
  func addBasicInfo() {
    self.addTitleSection(title: "Basic Information")
    guard let basicInfoInputVC = UserBasicInfoTableViewController.instantiate() else {
      print("Unable to instantiate basic info VC")
      return
    }
    self.addChild(basicInfoInputVC)
    basicInfoInputVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.stackView.addArrangedSubview(basicInfoInputVC.view)
    let height = CGFloat(basicInfoInputVC.infoItems.count * 60)
    basicInfoInputVC.view.addConstraint(NSLayoutConstraint(item: basicInfoInputVC.view as Any, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    
    basicInfoInputVC.tableView.isScrollEnabled = false
    basicInfoInputVC.didMove(toParent: self)
    self.addSpacer(space: 10.0)
  }
  
  func addMoreInfo() {
    self.addTitleSection(title: "More Information")
    guard let moreDetailsVC = UserMoreDetailsTableViewController.instantiate() else {
      print("Unable to instantiate basic info VC")
      return
    }
    self.addChild(moreDetailsVC)
    moreDetailsVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.stackView.addArrangedSubview(moreDetailsVC.view)
    let height = CGFloat(moreDetailsVC.infoItems.count * 60)
    moreDetailsVC.view.addConstraint(NSLayoutConstraint(item: moreDetailsVC.view as Any, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    moreDetailsVC.view.isUserInteractionEnabled = true
    moreDetailsVC.tableView.isScrollEnabled = false
    moreDetailsVC.didMove(toParent: self)
    self.addSpacer(space: 10.0)
  }
  
}

// MARK: - Keybaord Size Notifications
extension MeEditUserInfoViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserInfoViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(MeEditUserInfoViewController.keyboardWillHide(notification:)),
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
extension MeEditUserInfoViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeEditUserInfoViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
