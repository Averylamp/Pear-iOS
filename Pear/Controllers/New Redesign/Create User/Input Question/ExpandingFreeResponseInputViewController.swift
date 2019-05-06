//
//  ExpandingFreeResponseInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/30/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ExpandingFreeResponseInputViewController: UIViewController {
  
  var placeholderText: String! = ""
  @IBOutlet weak var expandingTextView: UITextView!
  @IBOutlet weak var expandingTextContainerView: UIView!
  @IBOutlet weak var expandingTextViewHeightConstraint: NSLayoutConstraint!
  
  var minTextViewSize: CGFloat = 64
  var animationDuration: Double = 0.3
  
  class func instantiate(placeholderText: String?) -> ExpandingFreeResponseInputViewController? {
    guard let expandingTextVC = R.storyboard.expandingFreeResponseInputViewController()
      .instantiateInitialViewController() as? ExpandingFreeResponseInputViewController else {
        print("Failed to instantiate Expanding Text VC")
        return nil
    }
    if let placeholder = placeholderText {
      expandingTextVC.placeholderText = placeholder
    }
    return expandingTextVC
  }
  
}

// MARK: - Life Cycle
extension ExpandingFreeResponseInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func getResponse() -> String? {
    if expandingTextView.text != self.placeholderText && self.expandingTextView.text != ""  && self.expandingTextView.text.count > 3 {
      return expandingTextView.text
    }
    return nil
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.recalculateTextViewHeight(animated: false)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.recalculateTextViewHeight(animated: false)
  }
  
  func setup() {
    self.expandingTextView.isScrollEnabled = false
    self.expandingTextView.delegate = self
  }
  
  func stylize() {
    self.expandingTextContainerView.layer.borderColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00).cgColor
    self.expandingTextContainerView.layer.borderWidth = 2
    self.expandingTextContainerView.layer.cornerRadius = 8
    self.expandingTextView.text = self.placeholderText
    self.expandingTextView.textColor = UIColor(white: 0.0, alpha: 0.3)
    self.expandingTextView.stylizeEditTextLabel()
    if let primaryTextColor = R.color.primaryTextColor() {
      self.expandingTextView.tintColor = primaryTextColor
    }
  }
  
}

// MARK: - UITextViewDelegate
extension ExpandingFreeResponseInputViewController: UITextViewDelegate {
  
  func recalculateTextViewHeight(animated: Bool = true) {
    if let viewHeightConstraint = self.expandingTextViewHeightConstraint {
      self.view.layoutIfNeeded()
      let textHeight = self.expandingTextView.sizeThatFits(CGSize(width: self.expandingTextView.frame.width,
                                                                  height: CGFloat.greatestFiniteMagnitude)).height + 2
      viewHeightConstraint.constant = max(minTextViewSize, textHeight)
      if animated {
        UIView.animate(withDuration: self.animationDuration) {
          self.view.layoutIfNeeded()
        }
      } else {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.view.endEditing(true)
      return false
    }
    if text.count + textView.text.count - range.length > 200 {
      return false
    }
    return true
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.recalculateTextViewHeight()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if self.expandingTextView.text == self.placeholderText {
      self.expandingTextView.text = ""
      self.expandingTextView.textColor = UIColor.black
      self.recalculateTextViewHeight()
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if self.expandingTextView.text == "" {
      self.expandingTextView.text = self.placeholderText
      self.expandingTextView.textColor = UIColor(white: 0.0, alpha: 0.3)
      self.recalculateTextViewHeight()
    }
  }
  
}
