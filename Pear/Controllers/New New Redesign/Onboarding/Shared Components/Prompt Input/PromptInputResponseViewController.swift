//
//  PromptInputResponseViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PromptInputResponseViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(question: QuestionItem) -> PromptInputResponseViewController? {
    guard let promptInputResponseVC = R.storyboard.promptInputResponseViewController()
      .instantiateInitialViewController() as? PromptInputResponseViewController else { return nil }
    return promptInputResponseVC
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension PromptInputResponseViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
  }
  
}
