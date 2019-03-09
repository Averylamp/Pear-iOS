//
//  ExpandingTextViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ExpandingTextViewControllerDelegate: class {
  func returnKeyPressed(expandingTextViewController: ExpandingTextViewController)
  func primaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton)
  func seccondaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton)
  func textViewDidChange(expandingTextViewController: ExpandingTextViewController)
}

class ExpandingTextViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  weak var delegate: ExpandingTextViewControllerDelegate?
  
  var viewHeightConstraint: NSLayoutConstraint?
  var animationDuration: Double = 0.3
  var minTextViewSize: CGFloat = 34
  var textLinePadding: CGFloat = 0
  var placeholderText: String?
  var placeholderTextColor: UIColor = UIColor(white: 0.4, alpha: 0.8)
  var textColor: UIColor = UIColor.black
  var tag: Int = 0
  var accessoryViewSize: CGFloat = 28
  var accessoryButtonRightOffset: CGFloat = 16
  
  @IBOutlet var textViewRightConstraint: NSLayoutConstraint!
  var textViewRightAccessoryConstraint: NSLayoutConstraint?
  
  var primaryAccessoryButton: UIButton?
  var primaryAccessoryButtonRightConstraint: NSLayoutConstraint?
  var secondaryAccessoryButton: UIButton?
  @IBOutlet weak var permanentTextLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ExpandingTextViewController? {
    let storyboard = UIStoryboard(name: String(describing: ExpandingTextViewController.self), bundle: nil)
    guard let expandingTextVC = storyboard.instantiateInitialViewController() as? ExpandingTextViewController else { return nil }
    return expandingTextVC
  }
  
  func setPlaceholderText(text: String) {
    textView.text = text
    placeholderText = text
    textView.textColor = placeholderTextColor
  }
}

// MARK: - Life Cycle
extension ExpandingTextViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    textView.delegate = self
    
  }
  
}

enum ButtonType {
  case add
  case close
}

// MARK: - Accessory Buttons
extension ExpandingTextViewController {
  
  func addAccessoryButton(image: UIImage, buttonType: ButtonType) {
    var accessoryButton: UIButton?
    if primaryAccessoryButton == nil {
      primaryAccessoryButton = UIButton()
      accessoryButton = primaryAccessoryButton
      guard let accessoryButton = accessoryButton else { return }
      accessoryButton.translatesAutoresizingMaskIntoConstraints = false
      accessoryButton.addTarget(self, action: #selector(ExpandingTextViewController.primaryAccessoryButtonClicked(sender:)), for: .touchUpInside)
      self.view.addSubview(accessoryButton)
      textViewRightConstraint.isActive = false
      textViewRightAccessoryConstraint =
        NSLayoutConstraint(item: self.textView, attribute: .right, relatedBy: .equal, toItem: accessoryButton, attribute: .left, multiplier: 1.0, constant: 0.0)
      self.primaryAccessoryButtonRightConstraint =
        NSLayoutConstraint(item: accessoryButton, attribute: .right, relatedBy: .equal,
                           toItem: self.view, attribute: .right, multiplier: 1.0, constant: -accessoryButtonRightOffset)
      self.view.addConstraints([
        self.textViewRightAccessoryConstraint!,
        NSLayoutConstraint(item: accessoryButton, attribute: .centerY, relatedBy: .equal,
                           toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: accessoryButton, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: accessoryViewSize),
        NSLayoutConstraint(item: accessoryButton, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: accessoryViewSize),
        self.primaryAccessoryButtonRightConstraint!
        ])
      UIView.animate(withDuration: self.animationDuration) {
        self.view.layoutIfNeeded()
      }
    } else if secondaryAccessoryButton == nil,
      let primaryAccessoryButton = self.primaryAccessoryButton,
      let primaryAccessoryButtonRightConstraint = self.primaryAccessoryButtonRightConstraint {
      secondaryAccessoryButton = UIButton()
      accessoryButton = secondaryAccessoryButton
      guard let accessoryButton = accessoryButton else { return }
      accessoryButton.translatesAutoresizingMaskIntoConstraints = false
      accessoryButton.addTarget(self, action: #selector(ExpandingTextViewController.secondaryAccessoryButtonClicked(sender:)), for: .touchUpInside)
      self.view.addSubview(accessoryButton)
      primaryAccessoryButtonRightConstraint.isActive = false
      self.view.addConstraints([
        NSLayoutConstraint(item: primaryAccessoryButton, attribute: .right, relatedBy: .equal,
                           toItem: accessoryButton, attribute: .left, multiplier: 1.0, constant: -8.0),
        NSLayoutConstraint(item: accessoryButton, attribute: .centerY, relatedBy: .equal,
                           toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: accessoryButton, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: accessoryViewSize),
        NSLayoutConstraint(item: accessoryButton, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: accessoryViewSize),
        NSLayoutConstraint(item: accessoryButton, attribute: .right, relatedBy: .equal,
                           toItem: self.view, attribute: .right, multiplier: 1.0, constant: -accessoryButtonRightOffset)
        ])
    }
    
    // Style button
    if let accessoryButton = accessoryButton {
      accessoryButton.setImage(image, for: .normal)
      switch buttonType {
      case .add:
        accessoryButton.tag = 0
      case .close:
        accessoryButton.tag = 1
        
      }
    }
  }
  
  @objc func primaryAccessoryButtonClicked(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.primaryAccessoryButtonPressed(expandingTextViewController: self, sender: sender)
    }
  }
  
  @objc func secondaryAccessoryButtonClicked(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.seccondaryAccessoryButtonPressed(expandingTextViewController: self, sender: sender)
    }
  }
  
  func removeAllAccessoryButtons() {
    var removedAccessory = false
    if let primaryAccessory = self.primaryAccessoryButton,
      let primaryAccessoryRightConstraint = self.primaryAccessoryButtonRightConstraint,
      let textViewRightAccessoryConstraint = self.textViewRightAccessoryConstraint {
      primaryAccessory.removeFromSuperview()
      self.view.removeConstraint(primaryAccessoryRightConstraint)
      self.view.removeConstraint(textViewRightAccessoryConstraint)
      self.primaryAccessoryButton = nil
      self.primaryAccessoryButtonRightConstraint = nil
      removedAccessory = true
    }
    if let secondaryAccessory = self.secondaryAccessoryButton {
      secondaryAccessory.removeFromSuperview()
      self.secondaryAccessoryButton = nil
      removedAccessory = true
    }
    
    if removedAccessory {
      self.textViewRightConstraint = NSLayoutConstraint(item: self.textView, attribute: .right, relatedBy: .equal,
                                                        toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
      self.view.addConstraint(self.textViewRightConstraint!)
      UIView.animate(withDuration: self.animationDuration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}

// MARK: - UITextViewDelegate
extension ExpandingTextViewController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    if let viewHeightConstraint = self.viewHeightConstraint {
      let textHeight = self.textView.sizeThatFits(CGSize(width: self.textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
      viewHeightConstraint.constant = max(minTextViewSize, textLinePadding + textHeight)
      UIView.animate(withDuration: self.animationDuration) {
        self.view.layoutIfNeeded()
      }
    }
    if let delegate = self.delegate {
      delegate.textViewDidChange(expandingTextViewController: self)
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if let placeholderText = self.placeholderText, textView.text == placeholderText {
      textView.text = ""
      textView.textColor = textColor
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if let placeholderText = self.placeholderText, textView.text == "" {
      textView.text = placeholderText
      textView.textColor = placeholderTextColor
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n", let delegate = self.delegate {
      delegate.returnKeyPressed(expandingTextViewController: self)
      return false
    }
    return true
  }
  
}
