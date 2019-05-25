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
  @IBOutlet weak var inputTextContainerView: UIView!
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  
  var question: QuestionItem!
  var characterLimit: Int!
  var editMode: Bool!
  var previousResponse: QuestionResponseItem?
  var editIndex: Int?
  
  weak var promptInputDelegate: PromptInputDelegate?
  
  let inputTextViewMinHeight: CGFloat = 70
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(question: QuestionItem, editMode: Bool, previousResponse: QuestionResponseItem?, index: Int?) -> PromptInputResponseViewController? {
    guard let promptInputResponseVC = R.storyboard.promptInputResponseViewController()
      .instantiateInitialViewController() as? PromptInputResponseViewController else { return nil }
    promptInputResponseVC.question = question
    promptInputResponseVC.characterLimit = 5
    promptInputResponseVC.editMode = editMode
    promptInputResponseVC.previousResponse = previousResponse
    promptInputResponseVC.editIndex = index
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
    self.addKeyboardDismissOnTap()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.recalculateTextViewHeight(animated: false)
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
    if let font = R.font.openSansSemiBold(size: 16) {
      self.inputTextView.font = font
    }
    self.inputTextView.textColor = R.color.primaryTextColor()
    self.inputTextContainerView.layer.borderWidth = 2
    self.inputTextContainerView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    self.inputTextContainerView.layer.cornerRadius = 12
  }
  
}

extension PromptInputResponseViewController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    self.recalculateTextViewHeight(animated: true)
  }
  
  func recalculateTextViewHeight(animated: Bool = true) {
    if let viewHeightConstraint = self.textViewHeightConstraint {
      self.view.layoutIfNeeded()
      let textHeight = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.frame.width,
                                                                  height: CGFloat.greatestFiniteMagnitude)).height
      viewHeightConstraint.constant = max(self.inputTextViewMinHeight, textHeight)

      self.inputTextView.isScrollEnabled = false
      if animated {
        UIView.animate(withDuration: 0.4) {
          self.view.layoutIfNeeded()
        }
      } else {
        self.view.layoutIfNeeded()
      }
    }
  }
  
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

// MARK: - KeyboardEventsDismissTapProtocol
extension PromptInputResponseViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PromptInputResponseViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
