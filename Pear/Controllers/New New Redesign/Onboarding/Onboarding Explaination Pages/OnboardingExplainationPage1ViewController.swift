//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingExplainationPage1ViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage1ViewController? {
    guard let onboardingPage1VC = R.storyboard.onboardingExplainationPage1ViewController()
      .instantiateInitialViewController() as? OnboardingExplainationPage1ViewController else { return nil }
    
    return onboardingPage1VC
  }
  
}

// MARK: - Life Cycle
extension OnboardingExplainationPage1ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }

  func stylize() {
    
  }
  
}
