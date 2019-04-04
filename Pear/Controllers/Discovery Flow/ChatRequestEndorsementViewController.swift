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
  
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var sendRequestButton: UIButton!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var endorsedThumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
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
      delegate.createPearRequest(sentByUserID: self.userID, sentForUserID: self.endorsedUserID)
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
    self.thumbnailImageView.layer.borderColor = R.color.brandPrimaryLight()?.cgColor
    self.thumbnailImageView.clipsToBounds = true
    self.thumbnailImageView.contentMode = .scaleAspectFill
    self.endorsedThumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.width / 2.0
    self.endorsedThumbnailImageView.layer.borderWidth = 1.0
    self.endorsedThumbnailImageView.layer.borderColor = R.color.brandPrimaryLight()?.cgColor
    self.endorsedThumbnailImageView.clipsToBounds = true
    self.endorsedThumbnailImageView.contentMode = .scaleAspectFill
    
    self.titleLabel.stylizeRequestTitleLabel()
    self.subtitleLabel.stylizeRequestSubtitleLabel()
    self.titleLabel.text = "Pair \(self.userPersonName!) and \(self.requestPersonName!)"
    self.subtitleLabel.text = "Get the conversation started"
    self.sendRequestButton.stylizeDark()
  }
  
}
