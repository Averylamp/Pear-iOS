//
//  ProfileQuestionResponseViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileQuestionResponseViewController: UITextViewItemViewController {

  @IBOutlet weak var questionTitleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var responseSubtitleLabel: UILabel!
  @IBOutlet weak var responseBodyLabel: UILabel!
  
  var questionItem: QuestionResponseItem!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(questionItem: QuestionResponseItem) -> ProfileQuestionResponseViewController? {
    guard let bioVC = R.storyboard.profileQuestionResponseViewController
      .instantiateInitialViewController() else { return nil }
    bioVC.questionItem = questionItem
    return bioVC
  }
  
  override func intrinsicHeight() -> CGFloat {
    let responseTitleHeight = self.responseSubtitleLabel.isHidden ? 8 :
      self.responseSubtitleLabel.sizeThatFits(CGSize(width: self.responseSubtitleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height + 12
    return self.questionTitleLabel.sizeThatFits(CGSize(width: self.questionTitleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height +
      self.responseBodyLabel.sizeThatFits(CGSize(width: self.responseBodyLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height +
      responseTitleHeight + 16
  }
}

// MARK: - Life Cycle
extension ProfileQuestionResponseViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.questionTitleLabel.text = self.questionItem.question.questionText
    if let responseSubText = self.questionItem.responseTitle {
      self.responseSubtitleLabel.text = responseSubText
    } else {
      self.responseSubtitleLabel.isHidden = true
    }
    self.responseBodyLabel.text = self.questionItem.responseBody    
  }
  
}
