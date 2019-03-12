//
//  FullProfileStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileStackViewController: UIViewController {
  
  var userProfileData: GettingStartedUserProfileData!
  
  @IBOutlet var stackView: UIStackView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(userProfileData: GettingStartedUserProfileData) -> FullProfileStackViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileStackViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? FullProfileStackViewController else { return nil }
    profileStackViewVC.userProfileData = userProfileData
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension FullProfileStackViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Failed to find pear user")
      return
    }
    let creatorFirstName = user.firstName
    
    self.addDemographcsVC()
    if 0 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[0].image)
    }
    self.addBioVC(bioText: self.userProfileData.bio!, creatorFirstName: creatorFirstName)
    if 1 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[1].image)
    }
    self.addDemographcsVC()
    if 2 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[2].image)
    }
    self.addDemographcsVC()
    if 3 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[3].image)
    }
    self.addDemographcsVC()
    if 4 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[4].image)
    }
    
    if 5 < self.userProfileData.images.count {
      self.addImageVC(image: self.userProfileData.images[5].image)
    }
    
  }
  
  func addDemographcsVC() {
    guard let demographicsVC = ProfileDemographicsViewController.instantiate(firstName: userProfileData.firstName!,
                                                                             age: userProfileData.age!,
                                                                             gender: userProfileData.gender!) else {
      print("Failed to create Demographics VC")
      return
    }
    
    self.stackView.addArrangedSubview(demographicsVC.view)
    
  }
  
  func addImageVC(image: UIImage) {
    guard let imageVC = ProfileImageViewController.instantiate(image: image) else {
      print("Failed to create Image VC")
      return
    }
    self.stackView.addArrangedSubview(imageVC.view)
  }
  
  func addBioVC(bioText: String, creatorFirstName: String) {
    guard let bioVC = ProfileBioViewController.instantiate(bioText: bioText, creatorFirstName: creatorFirstName) else {
      print("Failed to create bio VC")
      return
    }
    self.stackView.addArrangedSubview(bioVC.view)
  }

}
