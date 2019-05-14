//
//  ChatRequestPersonalViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol PearModalDelegate: class {
  func createPearRequest(sentByUserID: String, sentForUserID: String, requestText: String?)
  func dismissPearRequest()
}

class ChatRequestPersonalViewController: UIViewController {
  
  weak var delegate: PearModalDelegate?
  var userID: String!
  var thumbnailImageURL: URL!
  var requestPersonName: String!
  
  @IBOutlet weak var sendRequestButton: UIButton!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(personalUserID: String, thumbnailImageURL: URL, requestPersonName: String) -> ChatRequestPersonalViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatRequestPersonalViewController.self), bundle: nil)
    guard let chatRequestPersonalVC = storyboard.instantiateInitialViewController() as? ChatRequestPersonalViewController else { return nil }
    chatRequestPersonalVC.userID = personalUserID
    chatRequestPersonalVC.thumbnailImageURL = thumbnailImageURL
    chatRequestPersonalVC.requestPersonName = requestPersonName
    return chatRequestPersonalVC
  }
  @IBAction func dismissButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.dismissPearRequest()
    }
  }
  
  @IBAction func sendRequestButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.createPearRequest(sentByUserID: self.userID, sentForUserID: self.userID, requestText: nil)
    }
  }
  
}

// MARK: - Life Cycle
extension ChatRequestPersonalViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.thumbnailImageView.sd_setImage(with: self.thumbnailImageURL, completed: nil)
    self.stylize()
  }
  
  func stylize() {
    self.view.layer.cornerRadius = 20.0
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.width / 2.0
    self.thumbnailImageView.layer.borderWidth = 1.0
    self.thumbnailImageView.layer.borderColor = R.color.primaryBrandColor()?.cgColor
    self.thumbnailImageView.clipsToBounds = true
    self.thumbnailImageView.contentMode = .scaleAspectFill
    self.titleLabel.stylizeRequestTitleLabel()
    self.subtitleLabel.stylizeRequestSubtitleLabel()
    self.titleLabel.text = "Request to chat with \(self.requestPersonName!)"
    self.subtitleLabel.text = "If \(self.requestPersonName!) accepts, you'll be able to chat."
    self.sendRequestButton.stylizeDark()
  }
  
}
