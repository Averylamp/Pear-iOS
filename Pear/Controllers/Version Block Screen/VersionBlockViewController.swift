//
//  VersionBlockViewController.swift
//  Pear
//
//  Created by Brian Gu on 3/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class VersionBlockViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> VersionBlockViewController? {
    let storyboard = UIStoryboard(name: String(describing: VersionBlockViewController.self), bundle: nil)
    guard let versionBlockVC = storyboard.instantiateInitialViewController() as? VersionBlockViewController else { return nil }
    
    return versionBlockVC
  }
}

// MARK: - Life Cycle
extension VersionBlockViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
