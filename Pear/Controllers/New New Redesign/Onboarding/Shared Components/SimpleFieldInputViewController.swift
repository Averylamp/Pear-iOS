//
//  SimpleFieldInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class SimpleFieldInputViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> SimpleFieldInputViewController? {
    guard let inputFieldVC = R.storyboard.simpleFieldInputViewController()
      .instantiateInitialViewController() as? SimpleFieldInputViewController else {
        return nil
    }
    return inputFieldVC
  }

}

// MARK: - Life Cycle
extension SimpleFieldInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func setup() {
    
  }

}
