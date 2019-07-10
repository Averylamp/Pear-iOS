//
//  DiscoveryFilterOverlayViewController.swift
//  Pear
//
//  Created by Avery Lamp on 7/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryFilterOverlayViewController: UIViewController {
  
  @IBOutlet var overlayButton: UIButton!
  var topOffset: CGFloat = 100.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(topOffset: CGFloat) -> DiscoveryFilterOverlayViewController? {
    guard let filterOverlayVC = R.storyboard.discoveryFilterOverlayViewController
      .instantiateInitialViewController() else { return nil }
    filterOverlayVC.topOffset = topOffset
    return filterOverlayVC
  }
  
  @IBAction func overlayButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryFilterOverlayViewController {
  
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
