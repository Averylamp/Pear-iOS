//
//  LikeFullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class LikeFullProfileViewController: UIViewController {
  
  var fullProfile: FullProfileDisplayData!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfile: FullProfileDisplayData) -> LikeFullProfileViewController? {
    guard let likeFullProfileVC = R.storyboard.likeFullProfileViewController
      .instantiateInitialViewController() else { return nil }
    likeFullProfileVC.fullProfile = fullProfile
    return likeFullProfileVC
  }

}

// MARK: - Life Cycle
extension LikeFullProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }
  
}
