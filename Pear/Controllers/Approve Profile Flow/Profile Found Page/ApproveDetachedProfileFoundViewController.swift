//
//  DetachedProfileFoundViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

class ApproveDetachedProfileFoundViewController: UIViewController {

  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  var imageContainers: [GettingStartedUIImageContainer] = []
  var loadedImageContainersFromUser = false
  
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
    
    guard let updatePhotosVC = ApproveDetachedProfilePhotosViewController
      .instantiate(detachedProfile: self.detachedProfile,
                   displayedImages: imageContainers) else {
      print("Failed to instantiate Update Photos VC")
      return
    }
    
    self.navigationController?.pushViewController(updatePhotosVC, animated: true)
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ApproveDetachedProfileFoundViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    
    self.subtitleLabel.text = "\(self.detachedProfile.creatorFirstName!) started a profile for you. Choose your profile photos and see what they wrote."
  }
  
}
