//
//  DiscoveryDecisionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryDecisionViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoveryDecisionViewController? {
    guard let decisionDiscoveryVC = R.storyboard.discoveryDecisionViewController()
      .instantiateInitialViewController() as? DiscoveryDecisionViewController else {
        print("Failed to create decision based discovery VC")
        return nil
    }
    return decisionDiscoveryVC
  }
  
}

// MARK: - Life Cycle
extension DiscoveryDecisionViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
