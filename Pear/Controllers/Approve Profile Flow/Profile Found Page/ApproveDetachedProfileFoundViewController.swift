//
//  DetachedProfileFoundViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import NVActivityIndicatorView

class ApproveDetachedProfileFoundViewController: UIViewController {

  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  var imageContainers: (displayedImages: [LoadedImageContainer], imageBank: [LoadedImageContainer])?
  var loadedImageContainersFromUser = false
  var hasClickedNext = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileFoundViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileFoundViewController.self), bundle: nil)
    guard let detachedProfileFoundVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileFoundViewController else { return nil }
    detachedProfileFoundVC.detachedProfile = detachedProfile
    
    return detachedProfileFoundVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
//    guard let imageContainers = self.imageContainers else {
//      if hasClickedNext {
//        return
//      }
//      hasClickedNext = true
//      let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
//                                                      type: NVActivityIndicatorType.ballScaleRippleMultiple,
//                                                      color: StylingConfig.textFontColor,
//                                                      padding: 0)
//      self.view.addSubview(activityIndicator)
//      activityIndicator.center = CGPoint(x: self.view.center.x,
//                                         y: self.nextButton.frame.origin.y - 40)
//      activityIndicator.startAnimating()
//      return
//    }
//    guard let updatePhotosVC = ApproveDetachedProfilePhotosViewController
//      .instantiate(detachedProfile: self.detachedProfile,
//                   displayedImages: imageContainers.displayedImages,
//                   imageBank: imageContainers.imageBank) else {
//      print("Failed to instantiate Update Photos VC")
//      return
//    }
//
//    self.navigationController?.pushViewController(updatePhotosVC, animated: true)
    guard let fullProfileApprovalVC = ApproveProfileViewController.instantiate(profileData: FullProfileDisplayData(detachedProfile: self.detachedProfile)) else {
      print("Failed to create full detached profile view")
      return
    }
    self.navigationController?.pushViewController(fullProfileApprovalVC, animated: true)
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ApproveDetachedProfileFoundViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadUserImages()
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    
    self.subtitleLabel.text = "\(self.detachedProfile.creatorFirstName!) started a profile for you. Choose your profile photos and see what they wrote."
  }

  func loadUserImages() {
    if let currentUser = Auth.auth().currentUser {
      let uid = currentUser.uid
      currentUser.getIDToken { (token, error) in
        if let error = error {
          print(error)
          return
        }
        if let token = token {
          PearImageAPI.shared.getImages(uid: uid, token: token, completion: { (result) in
            switch result {
            case .success(let foundImages):
              var foundDisplayedImageContainers = foundImages.displayedImages
              if foundDisplayedImageContainers.count < 6 {
                foundDisplayedImageContainers
                  .append(contentsOf: Array(self.detachedProfile.images.prefix(6 - foundDisplayedImageContainers.count)))
              }
              var foundBankImages = foundImages.imageBank
              foundBankImages.append(contentsOf: self.detachedProfile.images)
              let displayedImagesContainers = foundDisplayedImageContainers.map({ $0.loadedImageContainer(size: .thumbnail) })
              let bankImages = foundBankImages.map({ $0.loadedImageContainer() })
              self.imageContainers = (displayedImages: displayedImagesContainers, imageBank: bankImages)
              print("Successfully loaded \(displayedImagesContainers.count) Displayed Images, \(bankImages.count) Bank Images")
              
            case .failure(let error):
              print(error)
              self.imageContainers = (displayedImages: self.detachedProfile.images.map({ $0.loadedImageContainer(size: .thumbnail )}),
                                      imageBank: self.detachedProfile.images.map({ $0.loadedImageContainer(size: .thumbnail )}))
            }
            
            if self.hasClickedNext {
              DispatchQueue.main.async {
                self.nextButtonClicked(self.nextButton as Any)
              }
            }
          })
        }
      }
    }
  }
}
