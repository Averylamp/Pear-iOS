//
//  PersonalLikeViewController.swift
//  Pear
//
//  Created by Brian Gu on 6/27/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PersonalLikeViewController: UIViewController {
  
  weak var delegate: PearModalDelegate?
  var userID: String!
  var thumbnailImageURL: URL!
  var requestPersonName: String!
  var likedPhoto: ImageContainer?
  var likedPrompt: QuestionResponseItem?
  let placeholderText: String = "Add a message..."
  var textViewHeightConstraint: NSLayoutConstraint?
  
  @IBOutlet var stackView: UIStackView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(personalUserID: String,
                         thumbnailImageURL: URL,
                         requestPersonName: String,
                         likedPhoto: ImageContainer? = nil,
                         likedPrompt: QuestionResponseItem? = nil) -> PersonalLikeViewController? {
    let storyboard = UIStoryboard(name: String(describing: PersonalLikeViewController.self), bundle: nil)
    guard let personalLikeVC = storyboard.instantiateInitialViewController() as? PersonalLikeViewController else { return nil }
    personalLikeVC.userID = personalUserID
    personalLikeVC.thumbnailImageURL = thumbnailImageURL
    personalLikeVC.requestPersonName = requestPersonName
    personalLikeVC.likedPhoto = likedPhoto
    personalLikeVC.likedPrompt = likedPrompt
    return personalLikeVC
  }
  
  @IBAction func sendRequestButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.createPearRequest(sentByUserID: self.userID, sentForUserID: self.userID, requestText: nil, likedPhoto: self.likedPhoto, likedPrompt: self.likedPrompt)
    }
  }
  
}

// MARK: - Life Cycle
extension PersonalLikeViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    if let likedPhoto = self.likedPhoto {
      self.addImageVC(imageContainer: likedPhoto)
    } else if let likedPrompt = self.likedPrompt {
      self.addPromptVC(prompt: likedPrompt)
    }
    self.addSpacerView(height: 20)
    self.addTextInputVC()
  }
  
  func stylize() {
    self.view.backgroundColor = UIColor.clear
    self.stackView.backgroundColor = UIColor.clear
  }
  
  func addSpacerView(height: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = UIColor.clear
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.stackView.addArrangedSubview(spacer)
  }
  
  func addImageVC(imageContainer: ImageContainer) {
    guard let imageVC = ProfileImageViewController.instantiate(imageContainer: imageContainer) else {
      print("Failed to create Image VC")
      return
    }
    imageVC.view.translatesAutoresizingMaskIntoConstraints = false
    let cardView = UIView()
    cardView.backgroundColor = UIColor.white
    cardView.layer.cornerRadius = 12
    cardView.clipsToBounds = true
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(imageVC.view)
    cardView.addConstraints([
      NSLayoutConstraint(item: imageVC.view, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageVC.view, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageVC.view, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageVC.view, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    self.addChild(imageVC)
    self.stackView.addArrangedSubview(cardView)
    imageVC.didMove(toParent: self)
  }
  
  func addPromptVC(prompt: QuestionResponseItem) {
    guard let promptVC = ProfileQuestionResponseViewController.instantiate(questionItem: prompt) else {
      print("Failed to create prompt VC")
      return
    }
    let cardView = UIView()
    promptVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChild(promptVC)
    cardView.backgroundColor = UIColor.green
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(promptVC.view)
    cardView.addConstraints([
      NSLayoutConstraint(item: promptVC.view, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: promptVC.view, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: promptVC.view, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: promptVC.view, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = UIColor.white
    scrollView.layer.cornerRadius = 12
    scrollView.clipsToBounds = true
    scrollView.addSubview(cardView)
    scrollView.contentSize = cardView.frame.size
    var scrollViewHeightConstraint = NSLayoutConstraint(item: cardView, attribute: .height, relatedBy: .equal,
                                                        toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
    scrollViewHeightConstraint.priority = .defaultLow
    scrollView.addConstraints([
      scrollViewHeightConstraint,
      NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .lessThanOrEqual,
                         toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal,
                         toItem: scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
      ])
    self.stackView.addArrangedSubview(scrollView)
    promptVC.didMove(toParent: self)
  }
  
  func addTextInputVC() {
    let textInputContainer = UIView()
    textInputContainer.translatesAutoresizingMaskIntoConstraints = false
    let textInputView = UITextView()
    textInputView.translatesAutoresizingMaskIntoConstraints = false
    if let textFont = R.font.openSansRegular(size: 17) {
      textInputView.font = textFont
    }
    textInputView.textColor = UIColor(white: 0.7, alpha: 1.0)
    textInputView.text = placeholderText
    textInputView.delegate =  self
    textInputView.isScrollEnabled = false
    
    textInputContainer.layer.cornerRadius = 10
    textInputContainer.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
    textInputContainer.layer.borderWidth = 1
    textInputContainer.backgroundColor = UIColor.white
    textInputContainer.addSubview(textInputView)
    textInputContainer.addConstraints([
      NSLayoutConstraint(item: textInputView, attribute: .left, relatedBy: .equal, toItem: textInputContainer, attribute: .left, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: textInputView, attribute: .right, relatedBy: .equal, toItem: textInputContainer, attribute: .right, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: textInputView, attribute: .top, relatedBy: .equal, toItem: textInputContainer, attribute: .top, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: textInputView, attribute: .bottom, relatedBy: .equal, toItem: textInputContainer, attribute: .bottom, multiplier: 1.0, constant: -8.0)
      ])
    textInputView.addConstraint(NSLayoutConstraint(item: textInputView, attribute: .height, relatedBy: .equal,
                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36.0))
    textInputView.delegate = self
    self.stackView.addArrangedSubview(textInputContainer)
    self.stackView.addConstraints([
      NSLayoutConstraint(item: textInputContainer, attribute: .left, relatedBy: .equal, toItem: self.stackView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: textInputContainer, attribute: .right, relatedBy: .equal, toItem: self.stackView, attribute: .right, multiplier: 1.0, constant: -20.0)
      ])
  }
  
}

// MARK: - UITextViewDelegate
extension PersonalLikeViewController: UITextViewDelegate {
  
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
