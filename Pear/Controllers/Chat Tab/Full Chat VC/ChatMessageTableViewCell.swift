//
//  ChatMessageTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ChatMessageCellDelegate: class {
  func clickedOnIcon()
}

class ChatMessageTableViewCell: UITableViewCell {

  @IBOutlet weak var chatBubbleButton: UIButton!
  @IBOutlet weak var chatContainerView: UIView!
  @IBOutlet weak var chatMessageLabel: UILabel!
  @IBOutlet weak var chatTimestampLabel: UILabel!
  @IBOutlet weak var chatThumbnailImageView: UIImageView?
  @IBOutlet weak var chatBackgroundImageView: UIImageView!
  
  weak var delegate: ChatMessageCellDelegate?
  var gradientLayer: CAGradientLayer?
  var timestamp: Date?

  override func awakeFromNib() {
    super.awakeFromNib()
    chatContainerView.layer.cornerRadius = 12
    chatContainerView.layer.masksToBounds = true
    if let chatThumbnailImageView = self.chatThumbnailImageView {
      chatThumbnailImageView.layer.cornerRadius = 25
    }

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

  }
  
  @IBAction func profileIconClicked(_ sender: Any) {
    if let delegate = delegate {
      delegate.clickedOnIcon()
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      if selected, let timestamp = timestamp {
        self.chatTimestampLabel.text = timestamp.timeAgoSinceDate()
      } else {
        self.chatTimestampLabel.text = nil
      }
    }
  
  func configure(message: Message) {
    guard message.type == .userMessage else {
      print("Not user message type")
      return
    }
    self.setNeedsLayout()
    self.layoutIfNeeded()
    if let existingGradientLayer = self.gradientLayer {
      existingGradientLayer.removeFromSuperlayer()
    }
    self.timestamp = message.timestamp
    chatMessageLabel.text = message.content

    self.chatMessageLabel.stylizeChatMessageText(sender: message.senderType == .sender)
    self.chatTimestampLabel.stylizeChatMessageTimestamp(sender: message.senderType == .sender)
    if let senderType = message.senderType, senderType == .sender {
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        chatThumbnailImageView.image = nil
      }

      self.chatContainerView.backgroundColor = R.color.chatAccentColor()
    } else {
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        if let thumbnailURL = message.thumbnailImage {
          chatThumbnailImageView.sd_setImage(with: thumbnailURL, completed: nil)
        } else {
          chatThumbnailImageView.image = nil
        }
      }
      self.chatContainerView.backgroundColor = R.color.chatGradientReceiverEnd()
    }
    self.setNeedsLayout()
  }

}
