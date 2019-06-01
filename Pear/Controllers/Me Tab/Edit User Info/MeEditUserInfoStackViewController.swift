//
//  MeEditUserInfoStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MeEditUserInfoStackViewController: UIViewController {
  
  @IBOutlet var stackView: UIStackView!
  
  var profile: FullProfileDisplayData!
  var pearUser: PearUser!
  var isUpdating: Bool = false

  weak var photoUpdateVC: UpdateImagesViewController?

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profile: FullProfileDisplayData,
                         pearUser: PearUser) -> MeEditUserInfoStackViewController? {
    guard let editUserInfoStackVC = R.storyboard.meEditUserInfoStackViewController
      .instantiateInitialViewController() else { return nil }
    editUserInfoStackVC.profile = profile
    editUserInfoStackVC.pearUser = pearUser
    return editUserInfoStackVC
  }

}

// MARK: - Life Cycle
extension MeEditUserInfoStackViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.stackView.addSpacer(height: 20.0)
    self.addPhotosSection()
    self.stackView.addSpacer(height: 10.0)
    self.addPromptsSection()
    self.stackView.addSpacer(height: 30.0)
    self.addBasicInfo()
    self.stackView.addSpacer(height: 20.0)
    self.addMoreInfo()
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }
  
}

// MARK: - Stack View Sections
extension MeEditUserInfoStackViewController {
  
  func addPhotosSection() {
    self.stackView.addTitleLabel(text: "Photos")
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
  
  func addPromptsSection() {
    self.stackView.addTitleLabel(text: "Prompts")
    guard let promptsVC = UpdateUserPromptsStackViewController.instantiate() else {
      print("Unable to instantiate prompts vc")
      return
    }
    self.addChild(promptsVC)
    
    self.stackView.addArrangedSubview(promptsVC.view)
    promptsVC.didMove(toParent: self)
    
  }
  
  func addBasicInfo() {
    self.stackView.addTitleLabel(text: "Basic Information")
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
    self.stackView.addSpacer(height: 10.0)
  }
  
  func addMoreInfo() {
    self.stackView.addTitleLabel(text: "More Information")
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
    self.stackView.addSpacer(height: 10.0)
  }
  
}
// MARK: - Updating and Saving
extension MeEditUserInfoStackViewController {
  
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
