//
//  ProfileQuestionResponseViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class NewProfileQuestionResponseViewController: UIViewController {

  @IBOutlet weak var writtenByImageView: UIImageView!
  @IBOutlet weak var writtenByLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var questionTitleLabel: UILabel!
  @IBOutlet weak var questionResponseLabel: UILabel!
  @IBOutlet weak var thumbnailImage: UIImageView!
  
  var questionItem: QuestionResponseItem!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(questionItem: QuestionResponseItem) -> NewProfileQuestionResponseViewController? {
    guard let questionResponseVC = R.storyboard.newProfileQuestionResponseViewController()
      .instantiateInitialViewController() as? NewProfileQuestionResponseViewController else { return nil }
    questionResponseVC.questionItem = questionItem
    return questionResponseVC
  }
  
}

// MARK: - Life Cycle
extension NewProfileQuestionResponseViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.writtenByImageView.contentMode = .scaleAspectFill
    self.writtenByImageView.layer.cornerRadius = self.writtenByImageView.frame.width / 2.0
    self.writtenByImageView.clipsToBounds = true
  }
  
  func setup() {
    self.writtenByLabel.text = questionItem.authorFirstName
    self.questionTitleLabel.text = questionItem.question.questionText
    self.questionResponseLabel.text = questionItem.responseBody
    if let authorThumbnailURL = self.questionItem.authorThumbnailURL,
      let thumbnailImage = self.thumbnailImage,
      let imageURL = URL(string: authorThumbnailURL) {
      thumbnailImage.sd_setImage(with: imageURL, completed: nil)
    }
  }
  
}
