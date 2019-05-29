//
//  UpdateUserPromptsStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UpdateUserPromptsStackViewController: UIViewController {

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UpdateUserPromptsStackViewController? {
    guard let updateUserPromptsVC = R.storyboard.updateUserPromptsStackViewController
      .instantiateInitialViewController() else { return nil }
    return updateUserPromptsVC
  }

}

// MARK: - Life Cycle
extension UpdateUserPromptsStackViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    
  }
  
  func stylize() {
    
  }
  
}
