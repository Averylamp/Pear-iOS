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
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var inputTextView: UITextView!
  
  var question: QuestionItem!
  var characterLimit: Int!
  var editMode: Bool!
  var previousResponse: QuestionResponseItem?
  var editIndex: Int?
  weak var promptInputDelegate: PromptInputDelegate?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(question: QuestionItem, editMode: Bool, previousResponse: QuestionResponseItem?, index: Int?) -> PromptInputResponseViewController? {
    guard let promptInputResponseVC = R.storyboard.promptInputResponseViewController()
      .instantiateInitialViewController() as? PromptInputResponseViewController else { return nil }
    promptInputResponseVC.question = question
    promptInputResponseVC.characterLimit = 5
    promptInputResponseVC.editMode = editMode
    if let previousResponse = previousResponse {
      promptInputResponseVC.previousResponse = previousResponse
    }
    if let index = index {
      promptInputResponseVC.editIndex = index
    }
    return promptInputResponseVC
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if self.editMode {
      self.navigationController?.dismiss(animated: true)
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func saveButtonClicked(_ sender: Any) {
    if self.editMode {
      if let previousResponse = self.previousResponse,
        let editIndex = self.editIndex {
        let questionResponse = try? QuestionResponseItem(documentID: previousResponse.documentID,
                                                         question: previousResponse.question,
                                                         responseBody: self.inputTextView.text,
                                                         responseTitle: nil,
                                                         color: nil,
                                                         icon: nil)
        if let delegate = self.promptInputDelegate,
          let editedResponse = questionResponse {
          delegate.editResponseAtIndex(questionResponse: editedResponse, index: editIndex)
        }
      }
    } else {
      let questionResponse = try? QuestionResponseItem(documentID: nil,
                                                     question: question,
                                                     responseBody: self.inputTextView.text,
                                                     responseTitle: nil,
                                                     color: nil,
                                                     icon: nil)
      if let delegate = self.promptInputDelegate,
        let newResponse = questionResponse {
        delegate.didAnswerPrompt(questionResponse: newResponse)
      }
    }
    self.navigationController?.dismiss(animated: true)
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
    self.questionLabel.text = self.question.questionText
    if let previousResponse = self.previousResponse {
      self.inputTextView.text = previousResponse.responseBody
    }
    self.inputTextView.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    if let font = R.font.openSansBold(size: 14) {
      self.questionLabel.font = font
    }
    if let font = R.font.openSansRegular(size: 14) {
      self.inputTextView.font = font
    }
    self.inputTextView.layer.borderWidth = 2
    self.inputTextView.layer.borderColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
    self.inputTextView.layer.cornerRadius = 12
  }
  
}

extension PromptInputResponseViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textViewText = textView.text,
      let rangeOfTextToReplace = Range(range, in: textViewText) else {
        return false
    }
    let substringToReplace = textViewText[rangeOfTextToReplace]
    let count = textViewText.count - substringToReplace.count + string.count
    if self.characterLimit > 0 {
      return count <= characterLimit
    }
    return true
  }
}
