//
//  OnboardingPicturesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class OnboardingPicturesViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  var photoUpdateVC: UpdateImagesViewController?
  var isContinuing: Bool = false
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingPicturesViewController? {
    guard let onboardingPicturesVC = R.storyboard.onboardingPicturesViewController()
      .instantiateInitialViewController() as? OnboardingPicturesViewController else { return nil }
    return onboardingPicturesVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if photoUpdateVC?.images.count == 0 {
      self.alert(title: "Please Upload 🎑", message: "You must have at least one image")
      return
    }

    self.updateUserImages()
  }
  
}

// MARK: - Permissions Flow Protocol
extension OnboardingPicturesViewController: PermissionsFlowProtocol {
  // No-Op
}

// MARK: - Update User Images
extension OnboardingPicturesViewController {
  
  func updateUserImages() {
    guard isContinuing == false else {
      return
    }
    self.isContinuing = true
    self.activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                     type: NVActivityIndicatorType.lineScalePulseOut,
                                                     color: StylingConfig.textFontColor,
                                                     padding: 0)
    self.view.addSubview(activityIndicator)
    activityIndicator.center = CGPoint(x: self.view.center.x,
                                       y: self.continueButton.frame.origin.y - 50)
    activityIndicator.startAnimating()

    if let photoVC = self.photoUpdateVC {
      let currentImageContainers = photoVC.images.compactMap({ $0.imageContainer })
      if currentImageContainers.count == photoVC.images.count {
        self.uploadImagesAndContinue()
      }
    }
  }

  func uploadImagesAndContinue() {
    if let userID = DataStore.shared.currentPearUser?.documentID,
      let photoVC = self.photoUpdateVC {
      let currentImageContainers = photoVC.images.compactMap({ $0.imageContainer })
      PearImageAPI.shared.updateImages(userID: userID,
                                       displayedImages: currentImageContainers,
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
                                        DispatchQueue.main.async {
                                          self.activityIndicator.stopAnimating()
                                          DataStore.shared.setFlagToDefaults(value: true, flag: .hasCompletedOnboarding)
                                          DataStore.shared.refreshPearUser(completion: { (_) in
                                            self.continueToMainVC()
                                          })
                                        }
      }
    }
  }
}

// MARK: - Image Upload Delegate
extension OnboardingPicturesViewController: UpdateImagesDelegate {
  
  func loadedAllImageContainers(imageContainers: [ImageContainer]) {
    if self.isContinuing {
      self.uploadImagesAndContinue()
    }
  }
  
}

// MARK: - Life Cycle
extension OnboardingPicturesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.setPreviousPageProgress()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.setCurrentPageProgress(animated: animated)
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
  }
  
  func setup() {
    let images = DataStore.shared.currentPearUser?.displayedImages.map({ $0.loadedImageContainer() }) ?? []
    guard let photosVC = UpdateImagesViewController.instantiate(images: images) else {
      print("failed to create photo edit VC")
      return
    }
    self.photoUpdateVC = photosVC
    self.photoUpdateVC?.imageUploadDelegate = self
    self.addChild(photosVC)
    self.stackView.addArrangedSubview(photosVC.view)
    photosVC.didMove(toParent: self)
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingPicturesViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 4
  }
  
  var progressBarTotalPages: Int {
    return 4
  }
}
