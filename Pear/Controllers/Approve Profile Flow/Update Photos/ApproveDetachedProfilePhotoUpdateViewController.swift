//
//  DetachedProfilePhotoUpdateViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveDetachedProfilePhotoUpdateViewController: UIViewController {

  var detachedProfile: PearDetachedProfile!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfilePhotoUpdateViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfilePhotoUpdateViewController.self), bundle: nil)
    guard let detachedProfilePhotoVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfilePhotoUpdateViewController else { return nil }
    detachedProfilePhotoVC.detachedProfile = detachedProfile
    return detachedProfilePhotoVC
  }
  
}

extension ApproveDetachedProfilePhotoUpdateViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
