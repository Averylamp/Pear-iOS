//
//  ExpandingBoastRoastInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ExpandingBoastRoastInputViewDelegate: class {
  func deleteButtonPressed(controller: ExpandingBoastRoastInputViewController)
  func returnPressed(controller: ExpandingBoastRoastInputViewController)
}

enum ExpandingBoastRoastInputType: String {
  case boast
  case roast
}

class ExpandingBoastRoastInputViewController: UIViewController {

  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var expandingTextView: UITextView!
  @IBOutlet weak var boastRoastImageView: UIImageView!
  @IBOutlet weak var expandingTextContainerView: UIView!
  @IBOutlet weak var expandingTextViewHeightConstraint: NSLayoutConstraint!
  
  weak var delegate: ExpandingBoastRoastInputViewDelegate?
  
  let boastPlaceholder = "A “pro” of dating them! Hype 👏 them 👏 up 👏"
  let roastPlaceholder = "Something people should know; nobody’s perfect ;P"
  
  let placeholderTextColor: UIColor = UIColor(white: 0.0, alpha: 0.3)
  var type: ExpandingBoastRoastInputType = .boast
  var minTextViewSize: CGFloat = 50
  var animationDuration: Double = 0.3
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(type: ExpandingBoastRoastInputType) -> ExpandingBoastRoastInputViewController? {
    guard let expandingTextVC = R.storyboard.expandingBoastRoastInputViewController()
      .instantiateInitialViewController() as? ExpandingBoastRoastInputViewController else { return nil }

    expandingTextVC.type = type
    return expandingTextVC
  }
  
  @IBAction func deleteButtonClicked(_ sender: Any) {
    if let expandingTVDelegate = self.delegate {
      expandingTVDelegate.deleteButtonPressed(controller: self)
    }
  }
  
  func getBoastRoastItem() -> BoastRoastItem? {
    if self.expandingTextView.text == boastPlaceholder ||
      self.expandingTextView.text == roastPlaceholder ||
      self.expandingTextView.text.count < 4 {
      return nil
    }
    switch self.type {
    case .boast:
      return BoastItem(content: self.expandingTextView.text)
    case .roast:
      return RoastItem(content: self.expandingTextView.text)
    }
  }
  
}

// MARK: - Life Cycle
extension ExpandingBoastRoastInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()
    self.stylize()
    self.populatePlaceholder(type: self.type)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.recalculateTextViewHeight(animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.recalculateTextViewHeight(animated: false)
  }
  
  func configure() {
    self.deleteButton.isHidden = false
    self.deleteButton.isEnabled = true
    self.expandingTextView.delegate = self
  }
  
  func stylize() {
    self.expandingTextContainerView.layer.cornerRadius = 12
    self.expandingTextContainerView.tintColor = UIColor.black
  }
  
  func populatePlaceholder(type: ExpandingBoastRoastInputType) {
    self.type = type
    switch self.type {
    case .boast:
      self.boastRoastImageView.image = R.image.iconBoast()
    case .roast:
      self.boastRoastImageView.image = R.image.iconRoast()
    }
    if self.expandingTextView.text != boastPlaceholder && self.expandingTextView.text != roastPlaceholder &&
      self.expandingTextView.text.count == 0 {
      switch self.type {
      case .boast:
        self.expandingTextView.text = boastPlaceholder
      case .roast:
        self.expandingTextView.text = roastPlaceholder
      }
      self.expandingTextView.textColor = self.placeholderTextColor
    } else {
      self.expandingTextView.textColor = UIColor.black
    }
    self.recalculateTextViewHeight(animated: true)
  }
  
}

// MARK: - UITextViewDelegate
extension ExpandingBoastRoastInputViewController: UITextViewDelegate {
  
  func recalculateTextViewHeight(animated: Bool = true) {
    if let viewHeightConstraint = self.expandingTextViewHeightConstraint {
      self.view.layoutIfNeeded()
      let textHeight = self.expandingTextView.sizeThatFits(CGSize(width: self.expandingTextView.frame.width,
                                                                  height: CGFloat.greatestFiniteMagnitude)).height
      viewHeightConstraint.constant = max(minTextViewSize, textHeight)
      self.expandingTextView.isScrollEnabled = false
      
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
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if self.expandingTextView.text == boastPlaceholder || self.expandingTextView.text == roastPlaceholder {
      self.expandingTextView.text = ""
      self.expandingTextView.textColor = UIColor.black
    }
    self.isEditing = true
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if self.expandingTextView.text == "" {
      self.populatePlaceholder(type: self.type)
    }
    self.isEditing = false
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      if let delegate = delegate {
        delegate.returnPressed(controller: self)
      }
      return false
    }
    return true
  }
  
}
