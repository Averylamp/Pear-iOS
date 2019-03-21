//
//  FullProfileStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileStackViewController: UIViewController {
  
  var fullProfileData: FullProfileDisplayData!
  
  @IBOutlet var stackView: UIStackView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(userFullProfileData: FullProfileDisplayData) -> FullProfileStackViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileStackViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? FullProfileStackViewController else { return nil }
    profileStackViewVC.fullProfileData = userFullProfileData
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
    
    self.addDemographcsVC(firstName: self.fullProfileData.firstName,
                          age: self.fullProfileData.age,
                          gender: self.fullProfileData.gender)
    if 0 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[0])
    } else if 0 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[0])
    }
    self.addBioVC(bioContent: self.fullProfileData.bio)
    if 1 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[1])
    } else if 1 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[1])
    }
    self.addInterestsVC(interests: self.fullProfileData.interests)
    if 2 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[2])
    } else if 2 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[2])
    }
    
    self.addDoDontVC(doDontType: .doType, doDontContent: fullProfileData.dos)
    if 3 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[3])
    } else if 3 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[3])
    }
    
    self.addDoDontVC(doDontType: .dontType, doDontContent: fullProfileData.donts)
    if 4 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[4])
    } else if 4 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[4])
    }
    
    if 5 < self.fullProfileData.rawImages.count {
      self.addImageVC(image: self.fullProfileData.rawImages[5])
    } else if 5 < self.fullProfileData.imageContainers.count {
      self.addImageVC(imageContainer: self.fullProfileData.imageContainers[5])
    }
    
  }
  
  func addDemographcsVC(firstName: String,
                        age: Int,
                        gender: String) {
    guard let demographicsVC = ProfileDemographicsViewController.instantiate(firstName: firstName,
                                                                             age: age,
                                                                             gender: gender) else {
                                                                              print("Failed to create Demographics VC")
                                                                              return
    }
    
    self.addChild(demographicsVC)
    self.stackView.addArrangedSubview(demographicsVC.view)
    demographicsVC.didMove(toParent: self)
  }
  
  func addImageVC(image: UIImage) {
    guard let imageVC = ProfileImageViewController.instantiate(image: image) else {
      print("Failed to create Image VC")
      return
    }
    self.addChild(imageVC)
    self.stackView.addArrangedSubview(imageVC.view)
    imageVC.didMove(toParent: self)
  }
  
  func addImageVC(imageContainer: ImageContainer) {
    guard let imageVC = ProfileImageViewController.instantiate(imageContainer: imageContainer) else {
      print("Failed to create Image VC")
      return
    }
    self.addChild(imageVC)
    self.stackView.addArrangedSubview(imageVC.view)
    imageVC.didMove(toParent: self)
  }
  
  func addBioVC(bioContent: [BioContent]) {
    guard let bioVC = ProfileBioViewController.instantiate(bioContent: bioContent) else {
      print("Failed to create bio VC")
      return
    }
    self.addChild(bioVC)
    self.stackView.addArrangedSubview(bioVC.view)
    bioVC.didMove(toParent: self)
  }
  
  func addInterestsVC(interests: [String]) {
    guard let interestsVC = ProfileInterestsViewController.instantiate(interests: interests) else {
      print("Failed to create Interests VC")
      return
    }
    self.addChild(interestsVC)
    self.stackView.addArrangedSubview(interestsVC.view)
    interestsVC.didMove(toParent: self)
  }
  
  func addDoDontVC(doDontType: DoDontType, doDontContent: [DoDontContent]) {
    guard let doDontVC = ProfileDoDontViewController.instantiate(doDontType: doDontType, doDontContent: doDontContent) else {
      print("Failed to instantiate Do Dont VC")
      return
    }
    self.addChild(doDontVC)
    self.stackView.addArrangedSubview(doDontVC.view)
    doDontVC.didMove(toParent: self)
  }
  
}
