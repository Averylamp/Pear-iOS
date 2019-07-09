//
//  ChatRequestEndorsementViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ChatRequestEndorsementViewController: UIViewController {
 
  weak var delegate: PearModalDelegate?
  var userID: String!
  var endorsedUserID: String!
  var thumbnailImageURL: URL!
  var userPersonthumbnailImageURL: URL!
  var requestPersonName: String!
  var userPersonName: String!
  
  let placeholderText: String = "Send them both a message..."
  
  @IBOutlet weak var inputTextViewContainer: UIView!
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var sendRequestButton: UIButton!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var endorsedThumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  // swiftlint:disable:next function_parameter_count
  class func instantiate(personalUserID: String,
                         endorsedUserID: String,
                         thumbnailImageURL: URL,
                         requestPersonName: String,
                         userPersonName: String,
                         userPersonThumbnailURL: URL) -> ChatRequestEndorsementViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatRequestEndorsementViewController.self), bundle: nil)
    guard let chatRequestEndorsedVC = storyboard.instantiateInitialViewController() as? ChatRequestEndorsementViewController else { return nil }
    chatRequestEndorsedVC.userID = personalUserID
    chatRequestEndorsedVC.endorsedUserID = endorsedUserID
    chatRequestEndorsedVC.thumbnailImageURL = thumbnailImageURL
    chatRequestEndorsedVC.userPersonthumbnailImageURL = userPersonThumbnailURL
    chatRequestEndorsedVC.requestPersonName = requestPersonName
    chatRequestEndorsedVC.userPersonName = userPersonName
    return chatRequestEndorsedVC
  }
  @IBAction func dismissButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.dismissPearRequest()
    }
  }
  
  @IBAction func sendRequestButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      var requestText: String?
      if self.inputTextView.text != "" && self.inputTextView.text != self.placeholderText && self.inputTextView.text.count > 0 {
        requestText = self.inputTextView.text
      }
      delegate.createPearRequest(sentByUserID: self.userID, sentForUserID: self.endorsedUserID, requestText: requestText, likedPhoto: nil, likedPrompt: nil)
    }
  }
  
}

// MARK: - Life Cycle
extension ChatRequestEndorsementViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.thumbnailImageView.sd_setImage(with: self.thumbnailImageURL, completed: nil)
    self.endorsedThumbnailImageView.sd_setImage(with: self.userPersonthumbnailImageURL, completed: nil)
    self.stylize()
  }
  
  func stylize() {
    self.view.layer.cornerRadius = 20.0
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.width / 2.0
    self.thumbnailImageView.layer.borderWidth = 1.0
    self.thumbnailImageView.layer.borderColor = R.color.primaryBrandColor()?.cgColor
    self.thumbnailImageView.clipsToBounds = true
    self.thumbnailImageView.contentMode = .scaleAspectFill
    self.endorsedThumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.width / 2.0
    self.endorsedThumbnailImageView.layer.borderWidth = 1.0
    self.endorsedThumbnailImageView.layer.borderColor = R.color.primaryBrandColor()?.cgColor
    self.endorsedThumbnailImageView.clipsToBounds = true
    self.endorsedThumbnailImageView.contentMode = .scaleAspectFill
    
    self.titleLabel.stylizeRequestTitleLabel()
    self.subtitleLabel.stylizeRequestSubtitleLabel()
    self.titleLabel.text = "Pair \(self.userPersonName!) and \(self.requestPersonName!)"
    self.subtitleLabel.text = "Get the conversation started"
    self.sendRequestButton.stylizeDark()
    
    if let textFont = R.font.openSansRegular(size: 17) {
      self.inputTextView.font = textFont
    }
    self.inputTextView.textColor = UIColor(white: 0.7, alpha: 1.0)
    self.inputTextView.text = placeholderText
    self.inputTextView.delegate =  self
    self.inputTextView.isScrollEnabled = false
    
    self.inputTextViewContainer.layer.cornerRadius = 10
    self.inputTextViewContainer.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
    self.inputTextViewContainer.layer.borderWidth = 1
  }
  
}

// MARK: - UITextViewDelegate
extension ChatRequestEndorsementViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == self.placeholderText {
      textView.text = ""
      textView.textColor = StylingConfig.textFontColor
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = self.placeholderText
      textView.textColor = UIColor(white: 0.7, alpha: 1.0)
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if let textViewHeightConstraint = self.textViewHeightConstraint {
      let textHeight = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
      textViewHeightConstraint.constant = max(34, textHeight)
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if textView.text.count + text.count - range.length > 120 {
      return false
    }
    return true
  }
  
}
