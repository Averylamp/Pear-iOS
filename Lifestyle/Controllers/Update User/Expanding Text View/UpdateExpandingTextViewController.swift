//
//  UpdateExpandingTextViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol UpdateExpandingTextViewDelegate: class {
  func deleteButtonPressed(controller: UpdateExpandingTextViewController)
}

enum ExpandingTextViewControllerType: String {
  case bio
  case doType
  case dontType
  case unknown
}

class UpdateExpandingTextViewController: UpdateUIViewController {
  
  var initialText: String!
  var placeholderText: String?
  
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var expandingTextView: UITextView!
  @IBOutlet weak var expandingTextContainerView: UIView!
  @IBOutlet weak var expandingTextViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
  
  weak var delegate: UpdateExpandingTextViewDelegate?
  
  var expanding: Bool = true
  var fixedHeight: CGFloat?
  var allowDelete: Bool = false
  var type: ExpandingTextViewControllerType = .unknown
  var maxHeight: CGFloat?
  var minTextViewSize: CGFloat = 32
  var animationDuration: Double = 0.3
  var placeholderColor: UIColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00).withAlphaComponent(0.5)
  var textColor: UIColor = R.color.primaryTextColor()!
  
  class func instantiate(initialText: String = "") -> UpdateExpandingTextViewController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateExpandingTextViewController.self), bundle: nil)
    guard let expandingTextVC = storyboard.instantiateInitialViewController() as? UpdateExpandingTextViewController else { return nil }
    expandingTextVC.initialText = initialText
    return expandingTextVC
  }
  
  override func didMakeUpdates() -> Bool {
    return initialText != self.expandingTextView.text
  }
  
  @IBAction func deleteButtonClicked(_ sender: Any) {
    if let expandingTVDelegate = self.delegate {
      expandingTVDelegate.deleteButtonPressed(controller: self)
    }
  }
  
  func setPlaceholderText(placeholderText: String) {
    self.placeholderText = placeholderText
    self.updatePlaceholder()
  }
  
}

// MARK: - Life Cycle
extension UpdateExpandingTextViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()
    self.stylize()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.recalculateTextViewHeight(animated: false)
  }
  
  func configure() {
    if let fixedHeight = self.fixedHeight {
      expanding = false
      self.expandingTextViewHeightConstraint.constant = fixedHeight
    }
    if allowDelete {
      self.deleteButtonWidthConstraint.constant = 30
      self.deleteButton.isHidden = false
      self.deleteButton.isEnabled = true
    } else {
      self.deleteButtonWidthConstraint.constant = 0
      self.deleteButton.isHidden = true
      self.deleteButton.isEnabled = false
    }
    self.expandingTextView.delegate = self
  }
  
  func stylize() {
    self.expandingTextContainerView.layer.borderColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00).cgColor
    self.expandingTextContainerView.layer.borderWidth = 2
    self.expandingTextContainerView.layer.cornerRadius = 8
    self.expandingTextView.text = self.initialText
    self.expandingTextView.stylizeEditTextLabel()
    self.expandingTextView.tintColor = self.textColor
  }
  
}

// MARK: - UITextViewDelegate
extension UpdateExpandingTextViewController: UITextViewDelegate {
  
  func recalculateTextViewHeight(animated: Bool = true) {
    if let viewHeightConstraint = self.expandingTextViewHeightConstraint {
      self.view.layoutIfNeeded()
      let textHeight = self.expandingTextView.sizeThatFits(CGSize(width: self.expandingTextView.frame.width,
                                                                  height: CGFloat.greatestFiniteMagnitude)).height
      viewHeightConstraint.constant = max(self.minTextViewSize, textHeight)
      if let maxHeight = self.maxHeight, maxHeight < viewHeightConstraint.constant {
        self.expandingTextView.isScrollEnabled = true
        viewHeightConstraint.constant = maxHeight
      } else {
        self.expandingTextView.isScrollEnabled = false
      }
      if animated {
        UIView.animate(withDuration: self.animationDuration) {
          self.view.layoutIfNeeded()
        }
      } else {
         self.view.layoutIfNeeded()
      }
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.recalculateTextViewHeight()
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    self.updatePlaceholder()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.updatePlaceholder(removePlaceholder: true)
  }
  
  func updatePlaceholder(removePlaceholder: Bool = false) {
    if let placeholder = self.placeholderText {
      if self.expandingTextView.text == "" || self.expandingTextView.text == placeholder {
        self.expandingTextView.textColor = self.placeholderColor
        self.expandingTextView.text = placeholder
      } else {
        self.expandingTextView.textColor = self.textColor
      }
      if removePlaceholder {
        self.expandingTextView.textColor = self.textColor
        self.expandingTextView.text = ""
      }
    }
  }
  
}
