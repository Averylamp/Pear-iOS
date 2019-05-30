//
//  PromptPickerViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PromptPickerViewController: UIViewController {
  
  var allPrompts: [QuestionResponseItem] = []
  var visiblePrompts: [QuestionResponseItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(allPrompts: [QuestionResponseItem],
                         visiblePrompts: [QuestionResponseItem]) -> PromptPickerViewController? {
    guard let promptPickerVC = R.storyboard.promptPickerViewController
      .instantiateInitialViewController() else { return nil }
    return promptPickerVC
  }

}

// MARK: - Life Cycle
extension PromptPickerViewController {
  
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
